# frozen_string_literal: true

require_relative 'constants'

module Obfuscator
  # A class responsible for naturalizing words, making them more readable and
  # natural-looking while preserving their structure.
  class Naturalizer
    include Constants

    def initialize(rng = Random.new)
      @rng = rng
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength,Metrics/PerceivedComplexity
    def naturalize(word)
      return word unless word.respond_to?(:to_s)
      return word if word.length < 2

      begin
        chars = word.chars
        result = []

        chars.each_with_index do |char, i|
          next_char = chars[i + 1]

          if next_char.nil?
            result << char
            next
          end

          # Rule 1: No ь/ъ after Latin letters
          soft_hard_signs = %w[ь ъ]
          if latin?(char) && soft_hard_signs.include?(next_char)
            chars[i + 1] = RUSSIAN_CONSONANTS.reject { |c| soft_hard_signs.include?(c) }.sample(random: @rng)
          end

          # Rule 2: No щ after w/th
          if (char == 'w' || (i.positive? && chars[i - 1] == 't' && char == 'h')) && next_char == 'щ'
            chars[i + 1] = (RUSSIAN_CONSONANTS - ['щ']).sample(random: @rng)
          end

          # Rule 3: No й after consonants
          chars[i + 1] = (RUSSIAN_CONSONANTS - ['й']).sample(random: @rng) if consonant?(char) && next_char == 'й'

          # Rule 4: No triple consonants
          if i < chars.length - 2 &&
             consonant?(char) &&
             consonant?(next_char) &&
             consonant?(chars[i + 2])
            chars[i + 1] = if cyrillic?(next_char)
                             RUSSIAN_VOWELS.sample(random: @rng)
                           else
                             ENGLISH_VOWELS.sample(random: @rng)
                           end
          end

          # Rule 5: Handle impossible combinations
          current_pair = char + next_char
          if IMPOSSIBLE_COMBINATIONS.any? { |combo| current_pair.include?(combo) }
            chars[i + 1] = if cyrillic?(next_char)
                             RUSSIAN_CONSONANTS.sample(random: @rng)
                           else
                             ENGLISH_CONSONANTS.sample(random: @rng)
                           end
          end

          # Rule 6: No double vowels
          if vowel?(char) && vowel?(next_char)
            chars[i + 1] = if cyrillic?(next_char)
                             RUSSIAN_CONSONANTS.sample(random: @rng)
                           else
                             ENGLISH_CONSONANTS.sample(random: @rng)
                           end
          end

          # Rule 7: Handle ё, ю, я after consonants
          # This rule is a special case of Rule 5
          soft_vowels = %w[ё ю я]
          if consonant?(char) && soft_vowels.include?(next_char)
            chars[i + 1] = (RUSSIAN_VOWELS - soft_vowels).sample(random: @rng)
          end

          result << char
        rescue StandardError => e
          raise Error, "Naturalization error for '#{word}': #{e.message}"
        end
      end

      # Rule 8: Apply appropriate ending if word is long enough
      final_word = result.join
      if final_word.length > 4
        if mostly_russian?(final_word)
          apply_russian_ending(final_word)
        elsif mostly_english?(final_word)
          apply_english_ending(final_word)
        else
          final_word
        end
      else
        final_word
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength,Metrics/PerceivedComplexity

    private

    def latin?(char)
      char.match?(/[a-zA-Z]/)
    end

    def cyrillic?(char)
      char.match?(/[а-яёА-ЯЁ]/)
    end

    def consonant?(char)
      down_char = char.downcase
      ENGLISH_CONSONANTS.include?(down_char) || RUSSIAN_CONSONANTS.include?(down_char)
    end

    def vowel?(char)
      down_char = char.downcase
      ENGLISH_VOWELS.include?(down_char) || RUSSIAN_VOWELS.include?(down_char)
    end

    def mostly_russian?(word)
      russian_chars = word.chars.count { |c| cyrillic?(c) }
      russian_chars > word.length / 2
    end

    def mostly_english?(word)
      english_chars = word.chars.count { |c| latin?(c) }
      english_chars > word.length / 2
    end

    def apply_russian_ending(word)
      return word if word.length < 4

      base = word[0...-2]
      base + RUSSIAN_ENDINGS.sample(random: @rng)
    end

    def apply_english_ending(word)
      return word if word.length < 4

      base = word[0...-2]
      base + ENGLISH_ENDINGS.sample(random: @rng)
    end
  end
end
