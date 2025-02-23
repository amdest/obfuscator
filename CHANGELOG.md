# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.8.1] - 2024-02-23

### Changed
- Updated RELEASE_CHECKLIST.md with Git workflow guide

## [0.8.0] - 2024-02-23

### Changed
- Enhanced top-level documentation with comprehensive NumberObfuscator examples
- Improved bilingual documentation symmetry in README
- Updated gem description to better reflect all features
- Made thread safety warnings more prominent

### Fixed
- Corrected and standardized examples across both languages in README
- Fixed missing US format examples in Russian documentation
- Fixed missing short format examples in English documentation
- Synchronized error handling examples between languages

## [0.7.0] - 2024-02-22

### Changed
- Clarified thread safety requirements in documentation
- Updated gem description to better reflect current capabilities
- Enhanced documentation with bilingual thread safety guidelines

### Fixed
- Corrected misleading thread safety claims in documentation
- Updated examples to show proper instance usage in concurrent scenarios
- Fixed DateObfuscator examples to match actual implementation

## [0.6.0] - 2024-02-22

### Added
- Support for IP-like number sequences (e.g., "21.11.234.23")
- Configurable unsigned mode for NumberObfuscator
- Improved decimal precision handling in float obfuscation

### Fixed
- Resolved repeating patterns in seeded number generation
- Fixed decimal places preservation in float obfuscation
- Corrected handling of leading zeros with format preservation
- Fixed sign handling in unsigned mode

### Changed
- Enhanced number generation algorithm for better randomization
- Improved format preservation for complex number patterns
- Optimized RNG state management for consistent results

## [0.5.0] - 2024-02-21

### Added
- Performance optimizations for NumberObfuscator with large numbers
- Added stress test mode for extreme number handling
- Improved test coverage for edge cases in number obfuscation
- Support for US date formats in DateObfuscator
- ISO full datetime format support

### Changed
- Adjusted number magnitude checks in tests for better reliability
- Made extreme number tests optional via STRESS_TEST environment variable
- Enhanced DateObfuscator format presets

### Fixed
- Performance issues with Float::MAX/MIN handling in NumberObfuscator
- DateObfuscator now properly handles seeds with different input dates
- Added combined seed calculation to ensure unique but reproducible results for different dates
- Added test coverage for seed behavior with different inputs

## [0.4.0] - 2024-02-21

### Added
- NumberObfuscator class for handling numeric content
- Support for Cyrillic alphabet in mixed content with numbers
- Format preservation for decimal and thousand separators
- Leading zeros handling with configuration option
- UTF-8 encoding support for mixed content
- Improved number format preservation

### Fixed
- Float decimal places preservation
- Character range issues with Cyrillic letters
- Length preservation in formatted numbers
- Mixed content handling with Unicode properties

### Changed
- Enhanced documentation with bilingual number obfuscation examples
- More robust number format preservation
- Improved mixed content handling

## [0.3.2] - 2025-02-07
### Added
- Test coverage for the Naturalizer class core functionality
- Test for sequential deterministic behavior in DateObfuscator

### Fixed
- Restored proper deterministic behavior for DateObfuscator and Naturalizer when using seed
- Fixed test naming to follow Ruby conventions (ASCII identifiers)
- Renamed the `test_obfuscator.rb` file into `obfuscator_test.rb` to follow Ruby conventions

## [0.3.1] - 2025-02-07
### Fixed
- Restored proper deterministic behavior for sequential obfuscation calls when using seed
- Fixed language detection for capitalized words
- Added test coverage for sequential determinism with seeds

## [0.3.0] - 2025-02-07
### Changed
- Renamed gem from 'obfuscator' to 'obfuscator-rb' for RubyGems.org publication
- Restructured main entry point for better gem compatibility
- Updated documentation to reflect new gem name

## [0.2.0] - 2025-02-06
### Added
- DateObfuscator class for handling date obfuscation
- Support for various date formats (EU, ISO, Russian)
- Configurable date constraints (year range, month/weekday preservation)
- Random number generation, array and range sampling helper methods

### Changed
- Refactored internal RNG handling for better maintainability and consistency
- Fixed seed handling to ensure proper reproducibility of results

## [0.1.0] - 2025-02-03
### Added
- Initial release
