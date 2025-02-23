# frozen_string_literal: true

require 'test_helper'
require 'date'
require_relative '../lib/obfuscator/date_obfuscator'

module Obfuscator
  class DateObfuscatorTest < Minitest::Test
    def setup
      @date_obf = Obfuscator::DateObfuscator.new
    end

    def test_handles_nil_input
      assert_nil @date_obf.obfuscate(nil)
    end

    def test_handles_empty_string
      assert_empty @date_obf.obfuscate('')
    end

    def test_raises_on_invalid_date
      assert_raises(Obfuscator::Error) do
        @date_obf.obfuscate('31.02.2023')  # Invalid February date
      end
    end

    def test_raises_on_invalid_format
      assert_raises(Obfuscator::Error) do
        @date_obf.obfuscate('2023.31.02')  # Doesn't match ISO format
      end
    end

    def test_preserves_format
      date = '2023-12-31'
      result = @date_obf.obfuscate(date)

      assert_match(/\d{4}-\d{2}-\d{2}/, result)
    end

    def test_different_formats
      dates = {
        eu:        '31.12.2023',
        eu_short:  '31.12.23',
        rus:       '31.12.2023',
        rus_short: '31.12.23',
        iso:       '2023-12-31'
      }

      dates.each do |format, date|
        obf = Obfuscator::DateObfuscator.new(format: format)
        result = obf.obfuscate(date)

        refute_equal date, result, "Date should be different for #{format} format"

        # Verify format is preserved
        case format
        when :eu, :rus

          assert_match(/\d{2}\.\d{2}\.\d{4}/, result)
        when :eu_short, :rus_short

          assert_match(/\d{2}\.\d{2}\.\d{2}/, result)
        when :iso

          assert_match(/\d{4}-\d{2}-\d{2}/, result)
        end
      end
    end

    def test_respects_year_constraints
      constraints = { min_year: 2020, max_year: 2025 }
      date = '2023-06-15'
      obf = Obfuscator::DateObfuscator.new(constraints: constraints)

      10.times do
        result = obf.obfuscate(date)
        year = result.split('-').first.to_i

        assert_includes 2020..2025, year
      end
    end

    def test_preserves_month_when_configured
      date = '2023-06-15'
      obf = Obfuscator::DateObfuscator.new(constraints: { preserve_month: true })

      result = obf.obfuscate(date)

      assert_equal '06', result.split('-')[1]
    end

    def test_preserves_weekday_when_configured
      date = '2023-06-15' # This was a Thursday
      obf = Obfuscator::DateObfuscator.new(constraints: { preserve_weekday: true })

      result = obf.obfuscate(date)
      original_date = Date.strptime(date, '%Y-%m-%d')
      result_date = Date.strptime(result, '%Y-%m-%d')

      assert_equal original_date.wday, result_date.wday
    end

    def test_produces_reproducible_output_with_seed
      date = '2023-06-15'
      obf1 = Obfuscator::DateObfuscator.new(seed: 12_345)
      obf2 = Obfuscator::DateObfuscator.new(seed: 12_345)

      assert_equal obf1.obfuscate(date), obf2.obfuscate(date)
    end

    def test_produces_reproducible_output_with_seed_sequentially
      date = '2023-06-15'
      obfuscator = DateObfuscator.new(seed: 12_345)

      result1 = obfuscator.obfuscate(date)
      result2 = obfuscator.obfuscate(date)

      assert_equal result1, result2,
                   'Sequential calls with same seed should produce identical results'
    end

    def test_generates_different_output_without_seed
      date = '2023-06-15'
      results = Set.new

      10.times do
        results.add(@date_obf.obfuscate(date))
      end

      assert_operator results.size, :>, 1, 'Should generate different dates'
    end

    def test_custom_format
      obf = Obfuscator::DateObfuscator.new(format: '%Y/%m/%d')
      date = '2023/06/15'

      result = obf.obfuscate(date)

      assert_match(%r{\d{4}/\d{2}/\d{2}}, result)
      refute_equal date, result
    end

    def test_produces_different_results_for_different_inputs_with_same_seed
      obfuscator = DateObfuscator.new(seed: 12_345)

      date1 = '2023-01-01'
      date2 = '2023-01-02'

      result1a = obfuscator.obfuscate(date1)
      result1b = obfuscator.obfuscate(date1)
      result2 = obfuscator.obfuscate(date2)

      assert_equal result1a, result1b,
                   'Same input with same seed should produce identical results'
      refute_equal result1a, result2,
                   'Different inputs with same seed should produce different results'
    end

    def test_produces_reproducible_results_across_instances
      date = '2023-01-01'

      obf1 = DateObfuscator.new(seed: 12_345)
      obf2 = DateObfuscator.new(seed: 12_345)

      result1 = obf1.obfuscate(date)
      result2 = obf2.obfuscate(date)

      assert_equal result1, result2,
                   'Same input and seed should produce identical results across instances'
    end
  end
end
