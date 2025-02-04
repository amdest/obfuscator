# frozen_string_literal: true

require_relative 'lib/obfuscator/version'

Gem::Specification.new do |spec|
  spec.name = 'obfuscator'
  spec.version = Obfuscator::VERSION
  spec.authors = ['Aleksandr Dryzhuk']
  spec.email = ['dev@ad-it.pro']

  spec.summary = 'Text obfuscator that preserves structure while working with both English and Russian languages'
  spec.description = <<~DESC
    A Ruby gem for text obfuscation that preserves text structure while replacing content
    with meaningless but natural-looking words. Supports both English and Russian languages,
    with various obfuscation modes and optional text naturalization.

    Гем для обфускации текста, сохраняющий его структуру и естественный вид, но заменяющий при этом содержимое
    бессмысленными словами. Поддерживает английский и русский языки, различные режимы обфускации и опциональную
    натурализацию текста.
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
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.require_paths = ['lib']
end
