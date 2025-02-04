# frozen_string_literal: true

module Obfuscator
  module Constants
    ENGLISH_CONSONANTS = %w[b c d f g h j k l m n p q r s t v w x y z].freeze
    ENGLISH_VOWELS = %w[a e i o u].freeze

    RUSSIAN_CONSONANTS = %w[б в г д ж з к л м н п р с т ф х ц ч ш щ].freeze
    RUSSIAN_VOWELS = %w[а е ё и о у ы э ю я].freeze

    # Impossible combinations in both languages
    IMPOSSIBLE_COMBINATIONS = %w[
      щщ щц щч щж щш щх
      жщ жж жц жч
      цщ цж цч
      чщ чж чц
      th щ th ж th ц th ч
      wa щ wa ж wa ц wa ч
    ].freeze

    # Typical Russian word endings
    RUSSIAN_ENDINGS = %w[
      ый ой ая ое ые ий ь
      ость ение ство ация
    ].freeze

    # Typical English word endings
    ENGLISH_ENDINGS = %w[
      ing ed ly tion sion
      ment ness ful less
    ].freeze
  end
end
