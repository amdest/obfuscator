# frozen_string_literal: true

# Obfuscator is a text obfuscation library that preserves text structure while replacing content
# with meaningless but natural-looking words. It supports both English and Russian languages,
# as well as numbers and dates with format preservation.
#
# The gem provides three main obfuscators:
# - {Multilang} for text obfuscation with multiple language support
# - {NumberObfuscator} for number and mixed content obfuscation
# - {DateObfuscator} for date obfuscation with format preservation
#
# THREAD SAFETY:
# Individual obfuscator instances are NOT thread-safe. For concurrent operations:
# - Create separate instances per thread
# - Do not share instances across threads
# - Each instance maintains its own RNG state
#
# @example Basic text obfuscation
#   require 'obfuscator-rb'
#
#   obfuscator = Obfuscator::Multilang.new
#   obfuscator.obfuscate("Hello, World!") # => "Kites, Mefal!"
#
# @example Number obfuscation with format preservation
#   num_obf = Obfuscator::NumberObfuscator.new
#   num_obf.obfuscate(123.45)          # => 567.89
#   num_obf.obfuscate("1,234.56")      # => "5,678.91"
#   num_obf.obfuscate("192.168.1.1")   # => "234.567.8.9"
#   num_obf.obfuscate("ABC-42XY")      # => "DEF-73ZW"
#
# @example Date obfuscation with constraints
#   date_obf = Obfuscator::DateObfuscator.new(
#     format: :iso,
#     constraints: {
#       min_year: 2020,
#       max_year: 2025,
#       preserve_month: true
#     }
#   )
#   date_obf.obfuscate("2023-12-31") # => "2025-12-15"
#
# @example Error handling
#   begin
#     obfuscator.obfuscate(input)
#   rescue Obfuscator::InputError => e
#     # Handle invalid input types
#   rescue Obfuscator::EncodingError => e
#     # Handle encoding issues
#   rescue Obfuscator::Error => e
#     # Handle other obfuscation errors
#   end
#
# Error handling is provided through specific error classes:
# - {Error} Base error class for the gem
# - {InputError} Raised for invalid input types
# - {EncodingError} Raised for encoding-related issues
#
# @see Multilang For text obfuscation functionality
# @see NumberObfuscator For number and mixed content obfuscation
# @see DateObfuscator For date obfuscation functionality
# @see Internal::RNG For random number generation utilities

module Obfuscator
  class Error < StandardError; end
  class EncodingError < Error; end
  class InputError < Error; end

  # Base module for the Obfuscator gem.
  #
  # THREAD SAFETY:
  # Individual obfuscator instances are NOT thread-safe. For concurrent operations:
  # - Create separate instances per thread
  # - Do not share instances across threads
  # - Each instance maintains its own RNG state
  #
  # @example Thread-safe usage
  #   threads = 4.times.map do
  #     Thread.new do
  #       # Create a new instance for each thread
  #       obfuscator = Obfuscator::NumberObfuscator.new(seed: 12345)
  #       obfuscator.obfuscate("123.45")
  #     end
  #   end
end

require_relative 'obfuscator/version'
require_relative 'obfuscator/constants'
require_relative 'obfuscator/internal/rng'
require_relative 'obfuscator/naturalizer'
require_relative 'obfuscator/multilang'
require_relative 'obfuscator/date_obfuscator'
require_relative 'obfuscator/number_obfuscator'

# Usage example:
if __FILE__ == $PROGRAM_NAME
  obfuscator = Obfuscator::Multilang.new(seed: 12_345)
  original_text = 'Hello, Мир! This is a TEST текст.'
  obfuscated = obfuscator.obfuscate(original_text)

  puts "Original: #{original_text}"
  puts "Obfuscated: #{obfuscated}" # 'Cumic, Фяц! Piwi ok c UBOH ричуг.'
end
