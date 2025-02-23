# frozen_string_literal: true

require 'date'
require_relative 'internal/rng'

module Obfuscator
  # Class for obfuscating dates while preserving their format and optionally some properties.
  #
  # Supports various date formats through presets or custom format strings.
  # Can preserve certain date characteristics (month, weekday) and respect year constraints.
  # All generated dates are valid - for example, it won't generate February 31st.
  #
  # @example Basic usage with preset format
  #   obfuscator = DateObfuscator.new
  #   obfuscator.obfuscate('2023-12-31')  # => "2025-07-15"
  #
  # @example With custom format string
  #   obfuscator = DateObfuscator.new(format: '%Y-%m-%d')
  #   obfuscator.obfuscate('2023-12-31')  # => "2025-07-15"
  #
  # @example With constraints
  #   obfuscator = DateObfuscator.new(
  #     constraints: {
  #       min_year: 2020,        # Minimum year to generate
  #       max_year: 2025,        # Maximum year to generate
  #       preserve_month: true,   # Keep the same month
  #       preserve_weekday: true  # Keep the same day of week
  #     }
  #   )
  #
  # @example With seed for reproducible results
  #   obfuscator = DateObfuscator.new(seed: 12345)
  #   obfuscator.obfuscate('2023-12-31')  # => Same result for same seed
  #
  # Available preset formats:
  # - :eu        => '%d.%m.%Y'  # 31.12.2023
  # - :eu_short  => '%d.%m.%y'  # 31.12.23
  # - :rus       => '%d.%m.%Y'  # 31.12.2023
  # - :rus_short => '%d.%m.%y'  # 31.12.23
  # - :iso       => '%Y-%m-%d'  # 2023-12-31
  # - :us        => '%m/%d/%Y'  # 12/31/2023
  # - :us_short  => '%m/%d/%y'  # 12/31/23
  # - :iso_full  => '%Y-%m-%dT%H:%M:%S%z'  # 2023-12-31T00:00:00+00:00
  #
  # @param format [Symbol, String] Preset format name or custom format string (default: :iso)
  # @param seed [Integer, nil] Optional seed for reproducible results
  # @param constraints [Hash] Optional constraints for date generation
  # @option constraints [Integer] :min_year Minimum year to generate (default: 2000)
  # @option constraints [Integer] :max_year Maximum year to generate (default: 2030)
  # @option constraints [Boolean] :preserve_month Keep the same month (default: false)
  # @option constraints [Boolean] :preserve_weekday Keep the same day of week (default: false)
  #
  # @raise [Error] If date string is invalid or doesn't match the format
  class DateObfuscator
    include Internal::RNG

    PRESET_FORMATS = {
      eu:        '%d.%m.%Y', # 31.12.2023
      eu_short:  '%d.%m.%y', # 31.12.23
      rus:       '%d.%m.%Y', # 31.12.2023
      rus_short: '%d.%m.%y', # 31.12.23
      iso:       '%Y-%m-%d', # 2023-12-31
      us:        '%m/%d/%Y', # 12/31/2023
      us_short:  '%m/%d/%y', # 12/31/23
      iso_full:  '%Y-%m-%dT%H:%M:%S%z' # 2023-12-31T00:00:00+00:00
    }.freeze

    def initialize(format: :iso, seed: nil, constraints: {})
      @seed = seed # Store the seed
      setup_rng(seed)
      @format = PRESET_FORMATS[format] || format
      @constraints = default_constraints.merge(constraints)
    end

    def obfuscate(date_string)
      return date_string if !date_string.is_a?(Date) && (date_string.nil? || date_string.empty?)

      begin
        date = date_string.is_a?(Date) ? date_string : ::Date.strptime(date_string, @format)

        # Create a unique seed based on both the original seed and input date
        if @seed
          combined_seed = [@seed, date.to_time.to_i].hash
          setup_rng(combined_seed)
        end

        obfuscated_date = generate_date(date)
        obfuscated_date.strftime(@format)
      rescue ArgumentError => e
        raise Error, "Invalid date or format: #{e.message}"
      end
    end

    private

    def default_constraints
      {
        min_year:         2000,
        max_year:         2030,
        preserve_month:   false,
        preserve_weekday: false
      }
    end

    def generate_date(original_date)
      year = random_year
      month = @constraints[:preserve_month] ? original_date.month : random_month
      day = random_day(year, month, original_date)

      ::Date.new(year, month, day)
    end

    def random_year
      random_range(@constraints[:min_year]..@constraints[:max_year])
    end

    def random_month
      random_range(1..12)
    end

    def random_day(year, month, original_date)
      days_in_month = ::Date.new(year, month, -1).day

      if @constraints[:preserve_weekday]
        # Find a day that falls on the same weekday
        target_weekday = original_date.wday
        possible_days = (1..days_in_month).select do |d|
          ::Date.new(year, month, d).wday == target_weekday
        end
        random_sample(possible_days)
      else
        random_range(1..days_in_month)
      end
    end
  end
end
