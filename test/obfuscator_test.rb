# frozen_string_literal: true

require 'test_helper'

class ObfuscatorMultilangTest < Minitest::Test
  def setup
    @obfuscator = Obfuscator::Multilang.new
  end

  def test_that_it_has_a_version_number
    refute_nil ::Obfuscator::VERSION
  end

  def test_handles_nil_input
    assert_nil @obfuscator.obfuscate(nil)
  end

  def test_handles_numeric_input
    assert_equal 42, @obfuscator.obfuscate(42)
    assert_in_delta(3.14, @obfuscator.obfuscate(3.14))
  end

  def test_rejects_input_without_to_s
    assert_raises(Obfuscator::InputError) do
      @obfuscator.obfuscate(BasicObject.new)
    end
  end

  def test_handles_invalid_encoding
    bad_string = String.new('Hello').force_encoding('ASCII-8BIT') # rubocop:disable Performance/UnfreezeString
    result = @obfuscator.obfuscate(bad_string)

    assert result, 'Should return a result with the forced UTF-8 encoding'
    assert_equal Encoding::UTF_8, result.encoding
  end

  def test_handles_encoding_errors
    bad_string = [0xFF].pack('C').force_encoding('UTF-8')
    assert_raises(Obfuscator::EncodingError) do
      @obfuscator.obfuscate(bad_string)
    end
  end

  def test_handles_invalid_encoding_raising_an_invalid_byte_sequence_error
    bad_string = String.new("\xC3\x28").force_encoding('UTF-8') # rubocop:disable Performance/UnfreezeString

    assert_raises Obfuscator::Error do
      @obfuscator.obfuscate(bad_string)
    end
  end

  def test_handles_mixed_content
    mixed_input = 'Text with number 42 and nil'
    result = @obfuscator.obfuscate(mixed_input)

    assert_includes result, '42'
  end

  def test_default_mode_preserves_source_language
    text = 'Hello Привет'
    result = @obfuscator.obfuscate(text)

    words = text.split
    result_words = result.split

    words.zip(result_words).each do |orig, obf|
      orig_lang = @obfuscator.send(:detect_language, orig)
      obf_lang = @obfuscator.send(:detect_language, obf)

      assert_equal orig_lang, obf_lang,
                   "Language mismatch: '#{orig}' (#{orig_lang}) -> '#{obf}' (#{obf_lang})"
    end
  end

  def test_preserves_punctuation
    text = 'Hello, World! Привет... мир?'
    result = @obfuscator.obfuscate(text)
    text = text.gsub(/[\p{L}\p{N}]+/, 'x')

    assert_equal text, result.gsub(/[\p{L}\p{N}]+/, 'x')

    obfuscator = Obfuscator::Multilang.new(mode: :mixed)
    result_mixed = obfuscator.obfuscate(text)

    result = result_mixed.gsub(/[\p{L}\p{N}]+/, 'x')

    assert_equal text, result,
                 "Punctuation mismatch: '#{text}' != '#{result}'"
  end

  def test_preserves_word_lengths
    text = 'Hello Привет'
    result = @obfuscator.obfuscate(text)
    original_lengths = text.split.map(&:length)
    result_lengths = result.split.map(&:length)

    assert_equal original_lengths, result_lengths
  end

  def test_naturalization_can_affect_word_length
    text = 'Test по-русски' * 20 # Use a longer text to increase probability
    mismatches = 0

    10.times do |i|
      # Use different seeds for each iteration to ensure different RNG states
      # and the same seed inside the loop to ensure repeatability
      seed = i + 1
      obf_without = Obfuscator::Multilang.new(mode: :mixed, seed: seed).obfuscate(text)
      obf_with = Obfuscator::Multilang.new(mode: :mixed, seed: seed, naturalize: true).obfuscate(text)

      mismatches += 1 if obf_without.length != obf_with.length
    end

    assert_predicate mismatches, :positive?,
                     'Naturalization never affected word length in 10 attempts'
  end

  def test_naturalization_doesnt_affect_short_word_length
    text = 'Test'
    obf_without = Obfuscator::Multilang.new(mode: :mixed).obfuscate(text)
    obf_with = Obfuscator::Multilang.new(mode: :mixed, naturalize: true).obfuscate(text)

    assert_equal obf_without.length, obf_with.length,
                 "Naturalization shouldn't affect word length for words < 2 characters long"
  end

  def test_preserves_capitalization
    text = 'Hello WORLD Привет МИР'
    result = @obfuscator.obfuscate(text)

    text_caps = text.chars.map { |c| c.match?(/[A-ZА-ЯЁ]/) }
    result_caps = result.chars.map { |c| c.match?(/[A-ZА-ЯЁ]/) }

    assert_equal text_caps, result_caps
  end

  def test_naturalization_can_affect_capitalization_pattern
    text = 'HelloWorld ПриветМир привет WORLD' * 20 # Multiple words to increase probability
    mismatches = 0

    10.times do |i|
      # Use different seeds for each iteration to ensure different RNG states
      # and the same seed inside the loop to ensure repeatability
      seed = i + 1
      obf_without = Obfuscator::Multilang.new(mode: :mixed, seed: seed).obfuscate(text)
      obf_with = Obfuscator::Multilang.new(mode: :mixed, seed: seed, naturalize: true).obfuscate(text)

      caps_without = obf_without.chars.map { |c| c.match?(/[A-ZА-ЯЁ]/) }
      caps_with = obf_with.chars.map { |c| c.match?(/[A-ZА-ЯЁ]/) }

      mismatches += 1 if caps_without != caps_with
    end

    assert_predicate mismatches, :positive?,
                     'Naturalization never affected capitalization pattern in 10 attempts'
  end

  def test_generates_different_output_each_time
    text = 'Hello World'
    result1 = @obfuscator.obfuscate(text)
    result2 = @obfuscator.obfuscate(text)

    refute_equal result1, result2
  end

  def test_produces_reproducible_output_with_seed
    text = 'Hello World'
    obf1 = Obfuscator::Multilang.new(mode: :mixed, seed: 12_345)
    obf2 = Obfuscator::Multilang.new(mode: :mixed, seed: 12_345)

    assert_equal obf1.obfuscate(text), obf2.obfuscate(text)
  end

  def test_produces_reproducible_output_with_seed_sequentially
    text = 'Hello World'
    obfuscator = Obfuscator::Multilang.new(seed: 12_345)

    result1 = obfuscator.obfuscate(text)
    result2 = obfuscator.obfuscate(text)

    assert_equal result1, result2,
                 'Sequential calls with same seed should produce identical results'
  end

  def test_handles_empty_string
    assert_equal '', @obfuscator.obfuscate('')
  end

  def test_handles_whitespace
    text = "   \t\n  "

    assert_equal text, @obfuscator.obfuscate(text)
  end

  def test_mixed_mode_uses_both_alphabets
    text = 'Hello Привет'
    result = @obfuscator.obfuscate(text)

    has_latin = result.match?(/[a-zA-Z]/)
    has_cyrillic = result.match?(/[а-яА-ЯЁё]/)

    assert has_latin && has_cyrillic
  end

  def test_naturalization_rules
    text = 'Test'
    result = @obfuscator.obfuscate(text)

    # Test that result doesn't contain invalid combinations
    refute_match(/[a-z][ьъ]/, result.downcase)
    refute_match(/щ$/, result)
    refute_match(/й[бвгджзклмнпрстфхцчшщ]/, result)
  end
end
