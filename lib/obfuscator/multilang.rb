# frozen_string_literal: true

require_relative 'constants'
require_relative 'internal/rng'
require_relative 'naturalizer'

module Obfuscator
  # A class responsible for obfuscating text in Russian and English languages.
  #
  # This class provides various modes for obfuscating text while preserving the original
  # text structure, whitespace, punctuation, and capitalization. The obfuscation can be
  # performed in several modes and optionally naturalized to produce more readable output.
  #
  # Available modes:
  # - MODE_DIRECT (default): Preserves language, replacing words with same-language random words
  # - MODE_ENG_TO_ENG: Only obfuscates English words, leaves Russian untouched
  # - MODE_RUS_TO_RUS: Only obfuscates Russian words, leaves English untouched
  # - MODE_SWAPPED: Swaps languages (English→Russian and Russian→English)
  # - MODE_MIXED: Generates words containing both English and Russian characters
  #
  # @example Basic usage
  #   obfuscator = Multilang.new
  #   obfuscator.obfuscate("Hello world!") # => "Kites mefal!"
  #
  # @example Using swapped mode with naturalization
  #   obfuscator = Multilang.new(mode: :swapped, naturalize: true)
  #   obfuscator.obfuscate("Hello мир!") # => "Привет world!"
  #
  # @param mode [Symbol] The obfuscation mode to use (default: MODE_DIRECT)
  # @param seed [Integer, nil] Optional seed for reproducible results
  # @param naturalize [Boolean] Whether to naturalize the output (default: false)
  #
  # @raise [InputError] If input doesn't respond to :to_s
  # @raise [EncodingError] If input has invalid encoding
  # @raise [Error] If obfuscation fails for any other reason
  class Multilang
    include Constants
    include Internal::RNG

    MODE_DIRECT = :direct # 1:1 obfuscation, the default
    MODE_ENG_TO_ENG = :eng_to_eng # eng/rus → eng/rus untouched
    MODE_RUS_TO_RUS = :rus_to_rus # eng/rus → eng untouched/rus
    MODE_SWAPPED = :swapped # eng→rus and rus→eng
    MODE_MIXED = :mixed # eng/rus → eng+rus mix just for fun

    def initialize(mode: MODE_DIRECT, seed: nil, naturalize: false)
      @mode = mode
      @seed = seed # Store the seed
      setup_rng(seed)
      @naturalizer = Naturalizer.new(seed) if naturalize
    end

    def obfuscate(input)
      # Reset RNG state before each obfuscation if seed was provided
      setup_rng(@seed) if @seed

      raise InputError, 'Input must respond to :to_s' unless input.respond_to?(:to_s)
      return input if input.nil? || input.is_a?(Numeric)

      text = input.to_s

      # Ensure UTF-8 encoding
      begin
        text = text.encode('UTF-8') unless text.encoding == Encoding::UTF_8
      rescue Encoding::InvalidByteSequenceError, Encoding::UndefinedConversionError => e
        raise EncodingError, "Encoding error: #{e.message}"
      end

      # Split preserving all whitespace and punctuation
      begin
        tokens = text.split(/(\s+|[[:punct:]])/)
        tokens.map do |token|
          if token.match?(/\s+|[[:punct:]]/)
            token # Preserve whitespace and punctuation
          else
            process_word(token)
          end
        end.join
      rescue ArgumentError => e
        raise EncodingError, "Encoding error: #{e.message}" if e.message.include?('invalid byte sequence')

        raise Error, "Obfuscation error: #{e.message}"
      rescue StandardError => e
        raise Error, "Obfuscation error: #{e.message}"
      end
    rescue NoMethodError => e
      raise InputError, "Input must be a Ruby object with basic methods: #{e.message}"
    end

    private

    def process_word(word)
      return word if word.empty?

      begin
        source_lang = detect_language(word)
        return word if source_lang == :unknown

        result = case @mode
                 when MODE_ENG_TO_ENG
                   source_lang == :english ? obfuscate_word(word, :english) : word
                 when MODE_RUS_TO_RUS
                   source_lang == :russian ? obfuscate_word(word, :russian) : word
                 when MODE_SWAPPED
                   target_lang = source_lang == :english ? :russian : :english
                   obfuscate_word(word, target_lang)
                 when MODE_MIXED
                   obfuscate_mixed_word(word)
                 when MODE_DIRECT
                   obfuscate_word(word, source_lang)
                 else
                   word
                 end

        @naturalizer ? @naturalizer.naturalize(result) : result
      rescue StandardError => e
        raise Error, "Word processing error for '#{word}': #{e.message}"
      end
    end

    def detect_language(word)
      first_char = word[0]
      return :russian if first_char.match?(/[а-яёА-ЯЁ]/)
      return :english if first_char.match?(/[a-zA-Z]/)

      :unknown
    end

    def obfuscate_word(word, target_lang)
      # Store capitalization pattern
      caps_pattern = word.chars.map { |char| char.match?(/[A-ZА-ЯЁ]/) }

      # Generate new word
      new_word = case target_lang
                 when :english
                   generate_english_word(word.length)
                 when :russian
                   generate_russian_word(word.length)
                 end

      # Apply capitalization pattern
      apply_caps_pattern(new_word, caps_pattern)
    end

    def obfuscate_mixed_word(word)
      caps_pattern = word.chars.map { |char| char.match?(/[A-ZА-ЯЁ]/) }
      new_word = generate_mixed_word(word.length)
      apply_caps_pattern(new_word, caps_pattern)
    end

    def generate_english_word(length)
      generate_word(length, ENGLISH_CONSONANTS, ENGLISH_VOWELS, 0.4)
    end

    def generate_russian_word(length)
      generate_word(length, RUSSIAN_CONSONANTS, RUSSIAN_VOWELS, 0.25)
    end

    def generate_word(length, consonants, vowels, vowel_start_prob)
      return '' if length.zero?

      result = ''
      is_vowel = random_probability < vowel_start_prob

      while result.length < length
        chars = is_vowel ? vowels : consonants
        result += random_sample(chars)
        is_vowel = !is_vowel
      end

      result[0...length]
    end

    def generate_mixed_word(length)
      return '' if length.zero?

      is_vowel = random_probability < 0.25

      result = ''
      while result.length < length
        # 50/50 chance of Russian or English
        use_russian = random_probability < 0.5

        # 25/75 chance of vowel for Russian/English
        # is_vowel = @rng.rand < (use_russian ? 0.25 : 0.4)

        char = if is_vowel
                 if use_russian
                   random_sample(RUSSIAN_VOWELS)
                 else
                   random_sample(ENGLISH_VOWELS)
                 end
               elsif use_russian
                 random_sample(RUSSIAN_CONSONANTS)
               else
                 random_sample(ENGLISH_CONSONANTS)
               end

        result += char
        is_vowel = !is_vowel
      end

      result[0...length]
    end

    def apply_caps_pattern(word, pattern)
      word.chars.map.with_index do |c, i|
        pattern[i] ? c.upcase : c.downcase
      end.join
    end

    def random_sample(array)
      array.sample(random: @rng)
    end

    def random_probability
      @rng.rand
    end
  end
end
