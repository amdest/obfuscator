# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'obfuscator'

require 'minitest/autorun'
require 'minitest/reporters'

unless ENV['RM_INFO']
  Minitest::Reporters.use! [
    # Minitest::Reporters::SpecReporter.new
    Minitest::Reporters::DefaultReporter.new(color: true, skip_passed: true)
  ]
end
