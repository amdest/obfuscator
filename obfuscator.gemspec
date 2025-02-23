# frozen_string_literal: true

require_relative 'lib/obfuscator/version'

Gem::Specification.new do |spec|
  spec.name = 'obfuscator-rb'
  spec.version = Obfuscator::VERSION
  spec.authors = ['Aleksandr Dryzhuk']
  spec.email = ['dev@ad-it.pro']

  spec.summary = 'A robust data obfuscator for numbers, dates, and text with format preservation'
  spec.description = <<~DESC
    A Ruby library for data obfuscation that:
    - Preserves original data format and structure as much as possible
    - Supports numbers (including IP-like sequences), dates, and text
    - Maintains text structure while replacing content with meaningless but natural-looking words in English and Russian
    - Maintains data type consistency and decimal precision
    - Offers seeded randomization for reproducible results
    - Handles various number formats (leading zeros, separators)
    - Provides configurable options (unsigned mode, format preservation)

    Note: Individual obfuscator instances are not thread-safe.
    For concurrent operations, create separate instances per thread.
  DESC
  spec.homepage = 'https://hub.mos.ru/ad/obfuscator'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.3.0'

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.each_line("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.require_paths = ['lib']
end
