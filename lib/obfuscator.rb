# frozen_string_literal: true

require_relative 'obfuscator/version'
require_relative 'obfuscator/constants'
require_relative 'obfuscator/naturalizer'
require_relative 'obfuscator/multilang'

module Obfuscator
  class Error < StandardError; end
  class EncodingError < Error; end
  class InputError < Error; end
end

# Usage example:
if __FILE__ == $PROGRAM_NAME
  obfuscator = Obfuscator::Multilang.new(seed: 12_345)

  original_text = 'Hello, Мир! This is a TEST текст.'
  obfuscated = obfuscator.obfuscate(original_text)

  puts "Original: #{original_text}"
  puts "Obfuscated: #{obfuscated}" # 'Cumic, Фяц! Piwi ok c UBOH ричуг.'
end
