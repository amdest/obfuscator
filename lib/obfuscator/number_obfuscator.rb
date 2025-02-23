# frozen_string_literal: true

module Obfuscator
  # Class for obfuscating numbers while preserving their format and structure.
  # Handles pure numbers (integers, floats), formatted strings, and mixed content
  # including multilingual text (Latin and Cyrillic alphabets).
  #
  # @example Basic usage with numbers
  #   obfuscator = NumberObfuscator.new
  #   obfuscator.obfuscate(123.45)     # => 567.89
  #   obfuscator.obfuscate(-42)        # => -73
  #
  # @example With string numbers and leading zeros
  #   obfuscator.obfuscate("0042")     # => "0073"
  #   obfuscator.obfuscate("00123.40") # => "00567.80"
  #
  # @example With formatted numbers
  #   obfuscator.obfuscate("1 234,56") # => "5 678,91"
  #   obfuscator.obfuscate("1_000_000") # => "5_678_912"
  #
  # @example With mixed content (Latin and Cyrillic)
  #   obfuscator.obfuscate("ABC-42XY")      # => "DEF-73ZW"
  #   obfuscator.obfuscate("АБВ-42ЩЮ")      # => "ГДЕ-73ЖЗ"
  #   obfuscator.obfuscate("21.11.234.23")  # => "65.87.891.45"
  #
  # @example With options
  #   # Don't preserve leading zeros
  #   obfuscator = NumberObfuscator.new(preserve_leading_zeros: false)
  #   obfuscator.obfuscate("0042") # => "7391"
  #
  #   # Remove signs from negative numbers
  #   obfuscator = NumberObfuscator.new(unsigned: true)
  #   obfuscator.obfuscate("-123") # => "456"
  #
  #   # Use seed for reproducible results
  #   obfuscator = NumberObfuscator.new(seed: 12345)
  #   obfuscator.obfuscate("123.45") # => Same result for same seed
  #
  # Features:
  # - Preserves number format (decimal separators, thousand separators)
  # - Maintains leading zeros (optional)
  # - Handles mixed content with letters and numbers
  # - Supports both Latin and Cyrillic alphabets
  # - Provides reproducible results with seeds
  # - UTF-8 encoding support
  #
  # @param preserve_leading_zeros [Boolean] Whether to keep leading zeros in string numbers (default: true)
  # @param unsigned [Boolean] Whether to remove signs from negative numbers (default: false)
  # @param seed [Integer, nil] Optional seed for reproducible results
  #
  # @raise [Error] If number obfuscation fails
  # @raise [InputError] If input is neither Numeric nor String
  #
  # @note This method is optimized for single-use. For bulk operations,
  #       consider creating a single instance and reusing it.
  #
  # @note This class is not thread-safe. For concurrent usage,
  #       create separate instances per thread.
  #
  # @note Requires Ruby 3.0+ for pattern matching features
  class NumberObfuscator
    include Internal::RNG

    FormatError = Class.new(Error)
    RangeError = Class.new(Error)

    # Consider memoizing character sets
    UPPERCASE_CYRILLIC = ('А'..'Я').to_a - ['Ё']
    LOWERCASE_CYRILLIC = ('а'..'я').to_a - ['ё']

    def initialize(preserve_leading_zeros: true, unsigned: false, seed: nil)
      @preserve_leading_zeros = preserve_leading_zeros
      @unsigned = unsigned
      @seed = seed # Store seed for reuse
      setup_rng(seed)
    end

    def obfuscate(input)
      return input if input.nil? || (input.is_a?(String) && input.empty?)

      # Create a unique seed based on both the original seed and input
      if @seed
        combined_seed = [@seed, input.to_s].hash
        setup_rng(combined_seed)
      end

      # Handle unsigned option at the entry point
      input = if @unsigned && input.is_a?(String)
                input.gsub(/^-/, '')
              elsif @unsigned && input.is_a?(Numeric)
                input.abs
              else
                input
              end

      case input
      when Numeric
        obfuscate_numeric(input)
      when String
        obfuscate_string(input)
      else
        raise InputError, "Input must be Numeric or String, got: #{input.class}"
      end
    rescue InputError
      raise
    rescue StandardError => e
      raise Error, "Number obfuscation error: #{e.message}"
    end

    private

    def preserve_format(original, new_number)
      return new_number if original.nil?
      return original if original.to_s.match?(/^-?0+\.?0*$/)

      original_str = original.to_s
      is_negative = original_str.start_with?('-') || new_number.negative?
      new_str = new_number.abs.to_s

      # Split into parts for IP-like numbers
      if original_str.count('.') > 1
        parts = original_str.gsub(/^-/, '').split('.')
        new_parts = parts.map do |part|
          part_len = part.length
          new_part = new_number.abs.to_s[-part_len..]
          new_part.rjust(part_len, '0')
        end
        new_str = new_parts.join('.')
      else
        # Handle decimal places
        if original_str.include?('.') || original_str.include?(',')
          separator = original_str.include?(',') ? ',' : '.'
          decimal_places = original_str.gsub(/^-/, '').split(/[.,]/).last&.length || 0
          new_str = format("%.#{decimal_places}f", new_number.abs).tr('.', separator)
        end

        # Handle leading zeros
        if @preserve_leading_zeros
          leading_zeros = original_str.gsub(/^-/, '').match(/^0+/)&.[](0)
          new_str = "#{leading_zeros}#{new_str}" if leading_zeros
        end

        # Ensure exact length match
        new_str = new_str.rjust(original_str.gsub(/^-/, '').length, '0')
      end

      # Add sign only if input was negative
      is_negative ? "-#{new_str}" : new_str
    end

    def obfuscate_string(text)
      return text if text.empty?

      # Split into numbers and separators while preserving positions
      parts = text.scan(/(\d+(?:\.\d+)?)|([^\d]+)/)
      parts.flatten!
      parts.compact!

      # Generate base seed for the entire string
      base_seed = if @seed
                    "#{@seed}:#{text}".hash
                  else
                    Random.new_seed
                  end

      result = ''
      numbers_count = parts.count { |p| p.match?(/\d/) }
      number_index = 0

      parts.each do |part|
        result += if part.match?(/\d/)
                    position_seed = "#{base_seed}:#{number_index}:#{numbers_count}".hash
                    local_rng = Random.new(position_seed)

                    number_result = with_temporary_rng(local_rng) do
                      original_str = @unsigned ? part.gsub(/^-/, '') : part
                      original = if original_str.include?('.')
                                   original_str.to_f
                                 else
                                   original_str.to_i
                                 end

                      new_number = generate_similar_number(original)
                      preserve_format(original_str, new_number)
                    end

                    number_index += 1
                    number_result
                  else
                    part
                  end
      end

      result
    end

    def obfuscate_mixed_string(text)
      # Split into tokens preserving all separators and non-numeric parts
      # \p{L} matches any kind of letter from any language
      # \p{N} matches any kind of numeric character in any script
      tokens = text.split(/(\d+(?:\.\d+)?|\s+|[[:punct:]]|[\p{L}]+)/)

      tokens.map do |token|
        case token
        when /^\d+(?:\.\d+)?$/ # Pure number
          new_number = generate_similar_number(token.to_f)
          preserve_format(token, new_number)
        when /\p{L}+/ # Letters (any script)
          obfuscate_letters(token)
        else # Spaces and punctuation
          token
        end
      end.join
    end

    def obfuscate_letters(text)
      # Ensure UTF-8 encoding
      text = text.encode('UTF-8') unless text.encoding == Encoding::UTF_8

      text.chars.map do |char|
        case char
        when /[A-Z]/
          (((char.ord - 'A'.ord + random_integer(1, 25)) % 26) + 'A'.ord).chr
        when /[a-z]/
          (((char.ord - 'a'.ord + random_integer(1, 25)) % 26) + 'a'.ord).chr
        when /[А-Я]/
          if char == 'Ё'
            'Е'
          else
            random_sample(UPPERCASE_CYRILLIC)
          end
        when /[а-я]/
          if char == 'ё'
            'е'
          else
            random_sample(LOWERCASE_CYRILLIC)
          end
        else
          char
        end
      end.join.force_encoding('UTF-8')
    end

    def obfuscate_numeric(number)
      return number if number.zero?

      case number
      when Integer
        # For integers, maintain the same number of digits
        digits = number.abs.to_s.length
        base = 10**(digits - 1)
        new_number = ((random_probability * 9) + 1) * base
        new_number = new_number.to_i

        # Handle sign based on unsigned option
        if @unsigned
          new_number.abs
        else
          number.negative? ? -new_number.abs : new_number.abs
        end

      when Float, BigDecimal
        # For floating point, maintain similar magnitude and precision
        str_number = number.to_s
        decimal_places = str_number.split('.')[1]&.length || 0
        new_number = generate_similar_number(number)

        # Ensure consistent decimal places
        new_number = new_number.round(decimal_places) if decimal_places.positive?

        # Handle sign based on unsigned option
        if @unsigned
          new_number.abs
        else
          number.negative? ? -new_number.abs : new_number.abs
        end

      else
        raise InputError, "Unsupported numeric type: #{number.class}"
      end
    end

    def generate_similar_number(number)
      return 0 if number.zero?

      # Work with absolute value
      abs_num = number.abs
      str_num = abs_num.to_s
      is_float = number.is_a?(Float) || str_num.include?('.')
      num_digits = str_num.gsub(/[^\d]/, '').length

      # Generate base number with correct digits
      base = 10**(num_digits - 1)
      max = (10**num_digits) - 1
      new_number = base + (random_probability * (max - base)).to_i

      # Handle float conversion and decimal places
      if is_float
        decimal_places = str_num.split('.')[1]&.length || 0
        new_number = (new_number.to_f / (10**decimal_places)).round(decimal_places)
      end

      # Handle sign based on unsigned option
      if @unsigned
        new_number.abs
      else
        number.negative? ? -new_number.abs : new_number.abs
      end
    end

    def random_integer(min, max)
      (random_probability * (max - min + 1)).to_i + min
    end

    def with_temporary_rng(temp_rng)
      original_rng = @rng
      @rng = temp_rng
      yield
    ensure
      @rng = original_rng
    end
  end
end
