# frozen_string_literal: true

require 'test_helper'

module Obfuscator
  class NaturalizerTest < Minitest::Test
    def setup
      @naturalizer = Naturalizer.new
    end

    def test_handles_short_words
      assert_equal 'a', @naturalizer.naturalize('a')
      assert_equal 'ab', @naturalizer.naturalize('ab')
    end

    def test_produces_reproducible_output_with_seed
      word = 'Thщит'
      nat1 = Naturalizer.new(12_345)
      nat2 = Naturalizer.new(12_345)

      assert_equal nat1.naturalize(word), nat2.naturalize(word)
    end

    def test_produces_reproducible_output_with_seed_sequentially
      word = 'Thщит'
      naturalizer = Naturalizer.new(12_345)

      result1 = naturalizer.naturalize(word)
      result2 = naturalizer.naturalize(word)

      assert_equal result1, result2,
                   'Sequential calls with same seed should produce identical results'
    end

    def test_handles_soft_hard_signs_after_latin
      result = @naturalizer.naturalize('abь')

      refute_match(/[a-z][ьъ]/, result.downcase)
    end

    def test_handles_shcha_after_th
      result = @naturalizer.naturalize('thщ')

      refute_match(/th[щ]/, result.downcase)
    end

    def test_handles_short_j_after_consonants
      result = @naturalizer.naturalize('tй')

      refute_match(/[бвгджзклмнпрстфхцчшщ]й/i, result)
    end

    def test_handles_triple_consonants
      result = @naturalizer.naturalize('стрк')

      refute_match(/[бвгджзклмнпрстфхцчшщ]{3}/i, result)
    end

    def test_handles_double_vowels
      result = @naturalizer.naturalize('aа')

      refute_match(/[аеёиоуыэюяaeiouy]{2}/i, result)
    end

    def test_handles_soft_vowels_after_consonants
      result = @naturalizer.naturalize('тё')

      refute_match(/[бвгджзклмнпрстфхцчшщ][ёюя]/i, result)
    end
  end
end
