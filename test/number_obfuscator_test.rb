# frozen_string_literal: true

require 'test_helper'
require_relative '../lib/obfuscator/number_obfuscator'

module Obfuscator
  class NumberObfuscatorTest < Minitest::Test
    def setup
      @obfuscator = NumberObfuscator.new
    end

    def test_handles_integers
      expected_length = 2 # '42'.length
      result = @obfuscator.obfuscate(42)

      assert_kind_of Integer, result
      assert_equal result.to_s.length, expected_length
    end

    def test_handles_negative_integers
      expected_length = 2 # '42'.length
      result = @obfuscator.obfuscate(-42)

      assert_predicate result, :negative?
      assert_equal result.abs.to_s.length, expected_length
    end

    def test_handles_floats
      input = 123.45
      result = @obfuscator.obfuscate(input)

      assert_kind_of Float, result
      assert_equal input.to_s.split('.')[1].length, result.to_s.split('.')[1].length
    end

    def test_handles_string_numbers
      input = '42'
      result = @obfuscator.obfuscate(input)

      assert_equal input.length, result.length
      assert_match(/^\d+$/, result)
    end

    def test_preserves_leading_zeros_by_default
      input = '0042'
      result = @obfuscator.obfuscate(input)

      assert_equal input.length, result.length
      assert_match(/^0+\d+$/, result)
    end

    def test_can_skip_leading_zeros_preservation
      obfuscator = NumberObfuscator.new(preserve_leading_zeros: false)
      input = '0042'
      result = obfuscator.obfuscate(input)

      assert_equal input.length, result.length
      assert_match(/^\d{4}$/, result)
    end

    def test_handles_formatted_numbers
      input = '1 234,56'
      result = @obfuscator.obfuscate(input)

      assert_equal input.length, result.length
      assert_match(/^\d[\s_]\d{3},\d{2}$/, result)
    end

    def test_handles_mixed_content
      input = 'ABC-42XY'
      result = @obfuscator.obfuscate(input)

      assert_equal input.length, result.length
      assert_match(/^[A-Z]+-\d+[A-Z]+$/, result)
    end

    def test_preserves_decimal_separators
      input = '123,45'
      result = @obfuscator.obfuscate(input)

      assert_match(/^\d+,\d+$/, result)

      input = '123.45'
      result = @obfuscator.obfuscate(input)

      assert_match(/^\d+\.\d+$/, result)
    end

    def test_handles_multiple_number_groups
      input = '21.11.234.23'
      result = @obfuscator.obfuscate(input)

      assert_equal input.length, result.length
      assert_match(/^\d+\.\d+(\.\d+)*$/, result)
    end

    def test_produces_reproducible_output_with_seed
      obf1 = NumberObfuscator.new(seed: 12_345)
      obf2 = NumberObfuscator.new(seed: 12_345)
      input = '123.45'

      assert_equal obf1.obfuscate(input), obf2.obfuscate(input)
    end

    def test_produces_reproducible_output_with_seed_sequentially
      obfuscator = NumberObfuscator.new(seed: 12_345)
      input = '123.45'

      result1 = obfuscator.obfuscate(input)
      result2 = obfuscator.obfuscate(input)

      assert_equal result1, result2,
                   'Sequential calls with same seed should produce identical results'
    end

    def test_handles_unsigned_option
      obfuscator = NumberObfuscator.new(unsigned: true)
      result = obfuscator.obfuscate('-42')

      refute_match(/^-/, result)
    end

    def test_handles_zero
      assert_equal '0', @obfuscator.obfuscate('0')
      assert_equal 0, @obfuscator.obfuscate(0)
      assert_equal '0.00', @obfuscator.obfuscate('0.00')
    end

    def test_raises_error_for_invalid_input
      assert_raises(InputError) { @obfuscator.obfuscate(:string) }
      assert_raises(InputError) { @obfuscator.obfuscate([]) }
    end

    def test_handles_mixed_content_with_cyrillic_uppercase
      input = 'АБВ-42ЩЮ'
      result = @obfuscator.obfuscate(input)

      assert_equal input.length, result.length
      assert_match(/^[А-ЯЁ]+-\d+[А-ЯЁ]+$/, result)
    end

    def test_handles_mixed_content_with_cyrillic_lowercase
      input = 'абв-42щю'
      result = @obfuscator.obfuscate(input)

      assert_equal input.length, result.length
      assert_match(/^[а-яё]+-\d+[а-яё]+$/, result)
    end

    def test_handles_large_numbers
      # Use large but not extreme numbers for regular testing
      large_positive = 1_000_000_000_000.0  # 1 trillion
      large_negative = -1_000_000_000_000.0 # -1 trillion

      result1 = @obfuscator.obfuscate(large_positive)

      assert_kind_of Float, result1, 'Should handle large positive numbers'
      assert_operator result1, :>, 0, 'Should generate positive number for positive input'
      assert_operator result1, :<, large_positive * 100, 'Should stay within reasonable magnitude'

      result2 = @obfuscator.obfuscate(large_negative)

      assert_kind_of Float, result2, 'Should handle large negative numbers'
      assert_operator result2, :<, 0, 'Should generate negative number for negative input'
      assert_operator result2.abs, :<, large_positive.abs * 100, 'Should stay within reasonable magnitude'
    end

    def test_handles_extreme_numbers
      skip 'Run with STRESS_TEST=1 to test extreme values' unless ENV['STRESS_TEST']

      # Use a large but not maximum value
      very_large = 1.0e+100 # Much smaller than Float::MAX but still very large

      result1 = @obfuscator.obfuscate(very_large)

      assert_kind_of Float, result1, 'Should handle very large numbers'
      assert_operator result1, :>, 0, 'Should generate positive number for positive input'
      assert_operator result1, :<, very_large * 100, 'Should stay within reasonable magnitude'

      result2 = @obfuscator.obfuscate(-very_large)

      assert_kind_of Float, result2, 'Should handle very large negative numbers'
      assert_operator result2, :<, 0, 'Should generate negative number for negative input'
      assert_operator result2.abs, :<, very_large * 100, 'Should stay within reasonable magnitude'
    end

    def test_seeded_obfuscation_differs_for_different_inputs
      obfuscator = NumberObfuscator.new(seed: 12_345)

      input1 = '10-20-30'
      input2 = '20-30-40'

      result1a = obfuscator.obfuscate(input1)
      result1b = obfuscator.obfuscate(input1)
      result2 = obfuscator.obfuscate(input2)

      assert_equal result1a, result1b,
                   'Same input with same seed should produce identical results'
      refute_equal result1a, result2,
                   'Different inputs with same seed should produce different results'
    end
  end
end
