# frozen_string_literal: true

module Obfuscator
  module Internal
    # Internal module providing Random Number Generation functionality.
    # This module is intended for internal use only and shouldn't be used directly by gem users.
    #
    # Provides consistent random number generation across the gem's classes,
    # with optional seed support for reproducible results.
    #
    # @api private
    #
    # Usage:
    #   include Internal::RNG
    #
    #   def initialize(seed = nil)
    #     setup_rng(seed)
    #   end
    #
    #   private
    #
    #   def some_method
    #     random_sample(some_array)      # For array sampling
    #     random_probability             # For random float between 0 and 1
    #     random_range(some_range)       # For range sampling
    #   end
    module RNG
      private

      def setup_rng(seed = nil)
        @rng = seed.nil? ? Random.new : Random.new(seed)
      end

      def random_sample(array)
        raise ArgumentError, "Expected Array, got #{array.class}" unless array.is_a?(Array)
        raise ArgumentError, 'Array cannot be empty' if array.empty?

        array.sample(random: @rng)
      end

      def random_probability
        @rng.rand
      end

      def random_range(range)
        raise ArgumentError, "Expected Range, got #{range.class}" unless range.is_a?(Range)
        raise ArgumentError, 'Range cannot be infinite' if range.end.nil?

        @rng.rand(range)
      end
    end
  end
end
