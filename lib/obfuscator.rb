# frozen_string_literal: true

# Obfuscator is a text obfuscation library that preserves text structure while replacing content
# with meaningless but natural-looking words. It supports both English and Russian languages.
#
# The gem provides two main obfuscators:
# - {Multilang} for text obfuscation with multiple language support
# - {DateObfuscator} for date obfuscation with format preservation
#
# @example Basic text obfuscation
#   obfuscator = Obfuscator::Multilang.new
#   obfuscator.obfuscate("Hello, World!") # => "Kites, Mefal!"
#
# @example Date obfuscation
#   date_obf = Obfuscator::DateObfuscator.new
#   date_obf.obfuscate("2023-12-31") # => "2025-07-15"
#
# Error handling is provided through specific error classes:
# - {Error} Base error class for the gem
# - {InputError} Raised for invalid input types
# - {EncodingError} Raised for encoding-related issues
#
# @see Multilang For text obfuscation functionality
# @see DateObfuscator For date obfuscation functionality
# @see Internal::RNG For random number generation utilities
module Obfuscator
  class Error < StandardError; end
  class EncodingError < Error; end
  class InputError < Error; end
end

require_relative 'obfuscator/version'
require_relative 'obfuscator/constants'
require_relative 'obfuscator/internal/rng'
require_relative 'obfuscator/naturalizer'
require_relative 'obfuscator/multilang'
require_relative 'obfuscator/date_obfuscator'

# Usage example:
if __FILE__ == $PROGRAM_NAME
  obfuscator = Obfuscator::Multilang.new(seed: 12_345)
  original_text = 'Hello, Мир! This is a TEST текст.'
  obfuscated = obfuscator.obfuscate(original_text)

  puts "Original: #{original_text}"
  puts "Obfuscated: #{obfuscated}" # 'Cumic, Фяц! Piwi ok c UBOH ричуг.'
end
