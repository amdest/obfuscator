# Obfuscator

[Русский](#русский) | [English](#english)

## Русский

Ruby-гем для обфускации текста. Сохраняет структуру, заменяя содержимое бессмысленными словами, сохраняющими при этом
естественный вид исходного текста. Поддерживает русский и английский языки.

### Установка

Добавьте эту строку в Gemfile вашего приложения:

```ruby
gem 'obfuscator', git: 'https://hub.mos.ru/ad/obfuscator.git'
```

И выполните:

```bash
$ bundle install
```

Или установите самостоятельно:

```bash
$ gem install obfuscator
```

### Возможности

- Сохраняет структуру текста (пунктуация, пробелы, регистр)
- Сохраняет длину слов (если не включена натурализация)
- Поддерживает несколько режимов обфускации
- Опциональная натурализация текста по некоторым простым правилам
- Необратимая трансформация текста
- Детерминированный вывод при использовании сида
- Полная поддержка UTF-8
- Обеспечена обработка ошибок определённых типов данных

### Использование

```ruby
require 'obfuscator'

# Базовое использование (режим :direct по умолчанию)
obfuscator = Obfuscator::Multilang.new
text = "Hello, Привет! This is a TEST текст."
result = obfuscator.obfuscate(text)
# => Каждое слово обфусцируется с использованием исходного алфавита

# Смешанный режим с обоими алфавитами
obfuscator = Obfuscator::Multilang.new(mode: :mixed)
result = obfuscator.obfuscate(text)
# => Слова могут содержать и латинские, и кириллические символы

# С натурализацией по простым правилам для более естественного вывода
obfuscator = Obfuscator::Multilang.new(mode: :mixed, naturalize: true)
result = obfuscator.obfuscate(text)
# => Вывод обрабатывается для более естественного вида

# С сидом для воспроизводимых результатов
obfuscator = Obfuscator::Multilang.new(seed: 12345)
result = obfuscator.obfuscate(text)
# => Одинаковый ввод + одинаковый сид = одинаковый вывод
```

### Доступные режимы

- `:direct` (по умолчанию) - сохраняет исходный язык для каждого слова
- `:eng_to_eng` - только английский в английский
- `:rus_to_rus` - только русский в русский
- `:swapped` - английский в русский и наоборот
- `:mixed` - использует оба алфавита (просто ради прикола)

### Обработка входных данных

Обфускатор обрабатывает разлличные типы данных:

- `nil` → возвращает nil
- Числа → возвращаются без изменений
- Объекты с методом `to_s` → обрабатываются нормально
- Объекты без базовых методов Ruby → вызывают `InputError`
- Неверные кодировки → вызывают `EncodingError`

#### Типы ошибок

- `Obfuscator::Error` - Базовый класс ошибок гема
- `Obfuscator::InputError` - Возникает при неверном типе входных данных
- `Obfuscator::EncodingError` - Возникает при проблемах с кодировкой

#### Пример использования с обработкой ошибок

```ruby

begin
  obfuscator.obfuscate(текст)
rescue Obfuscator::InputError => e
  # Обработка неверного типа входных данных
  puts "Неверный тип данных: #{e.message}"
rescue Obfuscator::EncodingError => e
  # Обработка проблем с кодировкой
  puts "Ошибка кодировки: #{e.message}"
rescue Obfuscator::Error => e
  # Обработка прочих ошибок обфускации
  puts "Ошибка обфускации: #{e.message}"
end
```

## English

A Ruby gem for text obfuscation that preserves text structure while replacing content with meaningless but
natural-looking words. Supports both English and Russian languages.

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'obfuscator', git: 'https://hub.mos.ru/ad/obfuscator.git'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install obfuscator
```

### Features

- Preserves text structure (punctuation, spacing, capitalization)
- Maintains word lengths (unless naturalization is enabled)
- Supports multiple obfuscation modes
- Optional text naturalization according to some basic rules
- Irreversible transformation
- Deterministic output with seeds
- Full UTF-8 support
- Comprehensive error handling with specific error types

### Usage

```ruby
require 'obfuscator'

# Basic usage (default :direct mode)
obfuscator = Obfuscator::Multilang.new
text = "Hello, Привет! This is a TEST текст."
result = obfuscator.obfuscate(text)
# => Each word is obfuscated using its source alphabet

# Mixed mode with both alphabets
obfuscator = Obfuscator::Multilang.new(mode: :mixed)
result = obfuscator.obfuscate(text)
# => Words may contain both Latin and Cyrillic characters

# With basic naturalization for more natural-looking output
obfuscator = Obfuscator::Multilang.new(mode: :mixed, naturalize: true)
result = obfuscator.obfuscate(text)
# => Output is processed to look more natural

# With seed for reproducible results
obfuscator = Obfuscator::Multilang.new(seed: 12345)
result = obfuscator.obfuscate(text)
# => Same input + same seed = same output
```

### Available Modes

- `:direct` (default) - preserves source language for each word
- `:eng_to_eng` - English to English only
- `:rus_to_rus` - Russian to Russian only
- `:swapped` - English to Russian and vice versa
- `:mixed` - uses both alphabets (just for fun)

### Input Handling

The obfuscator handles various input types:

- `nil` → returns nil
- Numbers → returns unchanged
- Objects responding to `to_s` → processes normally
- Objects without basic Ruby methods → raises `InputError`
- Invalid encodings → raises `EncodingError`

#### Error Types

- `Obfuscator::Error` - Base error class for the gem
- `Obfuscator::InputError` - Raised for invalid input types
- `Obfuscator::EncodingError` - Raised for encoding-related issues

#### Example Usage with Error Handling

```ruby

begin
  obfuscator.obfuscate(text)
rescue Obfuscator::InputError => e
  # Handle invalid input types
  puts "Invalid input: #{e.message}"
rescue Obfuscator::EncodingError => e
  # Handle encoding issues
  puts "Encoding error: #{e.message}"
rescue Obfuscator::Error => e
  # Handle other obfuscation errors
  puts "Obfuscation failed: #{e.message}"
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
