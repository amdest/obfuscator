# Obfuscator

[![Gem Version](https://badge.fury.io/rb/obfuscator-rb.svg)](https://badge.fury.io/rb/obfuscator-rb)

[Русский](#русский) | [English](#english)

## Русский

Ruby-гем для обфускации данных с сохранением их структуры и формата. Поддерживает:
- Текст на русском и английском языках
- Числа (включая IP-адреса и смешанный контент)
- Даты в различных форматах
- Воспроизводимые результаты через seed

### Установка

Добавьте эту строку в Gemfile вашего приложения:

```ruby
gem 'obfuscator-rb'
```

И выполните:

```bash
$ bundle install
```

Или установите самостоятельно:

```bash
$ gem install obfuscator-rb
```

Установка из репозитория [hub.mos.ru](https://hub.mos.ru/ad/obfuscator):

```bash
$ gem install obfuscator-rb --source https://hub.mos.ru/ad/obfuscator.git
```

Код также доступен на [GitHub](https://github.com/amdest/obfuscator) и [Gitverse](https://gitverse.ru/ad-it/obfuscator).

### Возможности

#### Обфускация чисел
- Сохраняет формат и структуру чисел (десятичные, тысячные разделители)
- Обрабатывает IP-подобные последовательности (например, "21.11.234.23")
- Поддерживает сохранение ведущих нулей (настраиваемо)
- Предоставляет режим для работы только с положительными числами
- Сохраняет точность десятичных дробей
- Обрабатывает смешанный контент с числами и текстом
- Поддерживает латинский и кириллический алфавиты

#### Обфускация дат
- Поддерживает множество форматов дат через пресеты (ISO, EU, US, русский)
- Сохраняет структуру и валидность формата
- Настраиваемые ограничения:
  - Диапазон допустимых лет
  - Сохранение месяца
  - Сохранение дня недели
- Обрабатывает полный формат ISO с временной зоной

#### Общие возможности
- Детерминированный вывод с опциональным сидом
- Обфускация с сохранением формата
- Поддержка кодировки UTF-8
- Комплексная обработка ошибок
- Эффективное использование памяти

#### Многопоточность
Отдельные экземпляры обфускаторов не являются потокобезопасными. Для многопоточных операций:
- Создавайте отдельный экземпляр для каждого потока
- Не используйте один экземпляр в разных потоках
- Каждый экземпляр поддерживает свое собственное состояние RNG

### Использование

```ruby
require 'obfuscator-rb'

# Обфускация текста (режим :direct по умолчанию)
obfuscator = Obfuscator::Multilang.new
text = "Hello, Привет! This is a TEST текст."
result = obfuscator.obfuscate(text)
# => Каждое слово обфусцируется с использованием исходного алфавита
# => "Idise, Кющэшэ! Izib oq g MUGU дипяд."

# Смешанный режим с обоими алфавитами
obfuscator = Obfuscator::Multilang.new(mode: :mixed)
result = obfuscator.obfuscate(text)
# => Слова могут содержать и латинские, и кириллические символы
# => "Fаyef, Фeфeгю! Muci лi r HЫЛO ицижё."

# С натурализацией по простым правилам для более естественного вывода
obfuscator = Obfuscator::Multilang.new(mode: :mixed, naturalize: true)
result = obfuscator.obfuscate(text)
# => Вывод обрабатывается для более естественного вида
# => "Ohеsion, Wорыой! Наvы мe л ЛУНI yeзing."

# С сидом для воспроизводимых результатов
obfuscator = Obfuscator::Multilang.new(seed: 12345)
result = obfuscator.obfuscate(text)
# => Одинаковый ввод + одинаковый сид = одинаковый вывод
# => "Cumic, Фяцёне! Okac ub h POWO щюзёс."

# Обфускация чисел
obfuscator = Obfuscator::NumberObfuscator.new
obfuscator.obfuscate(123.45)     # => 567.89
obfuscator.obfuscate("1 234,56") # => "5 678,91"
obfuscator.obfuscate("192.168.1.1") # => "234.567.8.9"

# С настройками
obfuscator = Obfuscator::NumberObfuscator.new(
  preserve_leading_zeros: false,  # Не сохранять ведущие нули
  unsigned: true,                 # Убрать знаки минус
  seed: 12345                    # Для воспроизводимых результатов
)
obfuscator.obfuscate("0042")     # => "7391"
obfuscator.obfuscate("-123")     # => "456"

# Обфускация даты
obfuscator = Obfuscator::DateObfuscator.new
obfuscator.obfuscate('2024-03-15')                    # => "2025-08-23"

# Разные форматы дат
eu = Obfuscator::DateObfuscator.new(format: :eu)      # Европейский формат
eu.obfuscate('15.03.2024')                            # => "23.08.2025"

us = Obfuscator::DateObfuscator.new(format: :us)      # Американский формат
us.obfuscate('03/15/2024')                            # => "08/23/2025"

rus_short = Obfuscator::DateObfuscator.new(format: :rus_short) # Короткий формат
rus_short.obfuscate('15.03.24')                       # => "23.08.25"

# С ограничениями
constrained = Obfuscator::DateObfuscator.new(
  format: :rus,
  constraints: {
    min_year: 2020,              # Не генерировать даты раньше 2020
    max_year: 2025,              # Не генерировать даты позже 2025
    preserve_month: true,        # Сохранять месяц
    preserve_weekday: true       # Сохранять день недели
  }
)
constrained.obfuscate('15.03.2024')  # => "14.03.2025" (тот же месяц, тот же день недели)

# С сидом для воспроизводимых результатов
seeded = Obfuscator::DateObfuscator.new(format: :rus, seed: 12345)
seeded.obfuscate('15.03.2024')          # => "21.07.2025" (постоянный результат)
```

### Доступные режимы

- `:direct` (по умолчанию) - сохраняет исходный язык для каждого слова
- `:eng_to_eng` - только английский в английский
- `:rus_to_rus` - только русский в русский
- `:swapped` - английский в русский и наоборот
- `:mixed` - использует оба алфавита

### Доступные пресеты для даты

- `:eu` => `'%d.%m.%Y'` - европейский формат (31.12.2023)
- `:eu_short` => `'%d.%m.%y'` - короткий европейский формат (31.12.23)
- `:rus` => `'%d.%m.%Y'` - русский формат (31.12.2023)
- `:rus_short` => `'%d.%m.%y'` - короткий русский формат (31.12.23)
- `:iso` => `'%Y-%m-%d'` - формат ISO (2023-12-31)
- `:us` => `'%m/%d/%Y'` - американский формат (12/31/2023)
- `:us_short` => `'%m/%d/%y'` - короткий американский формат (12/31/23)
- `:iso_full` => `'%Y-%m-%dT%H:%M:%S%z'` - полный формат ISO (2023-12-31T00:00:00+00:00)

### Обработка ошибок

```ruby
begin
  obfuscator.obfuscate(text)
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

A Ruby gem for data obfuscation that preserves structure and format. Supports:
- Text in both English and Russian
- Numbers (including IP addresses and mixed content)
- Dates in various formats
- Reproducible results via seeding

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'obfuscator-rb'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install obfuscator-rb
```

Install from [hub.mos.ru](https://hub.mos.ru/ad/obfuscator):

```bash
$ gem install obfuscator-rb --source https://hub.mos.ru/ad/obfuscator.git
```

The code is also available on [GitHub](https://github.com/amdest/obfuscator) and [Gitverse](https://gitverse.ru/ad-it/obfuscator).

### Features

#### Number Obfuscation
- Preserves number format and structure (decimals, thousand separators)
- Handles IP-like sequences (e.g., "21.11.234.23")
- Supports leading zeros preservation (configurable)
- Provides unsigned mode for positive-only output
- Maintains consistent decimal precision
- Processes mixed content with numbers and text
- Supports both Latin and Cyrillic alphabets

#### Date Obfuscation
- Supports multiple date formats through presets (ISO, EU, US, Russian)
- Preserves format structure and validity
- Configurable constraints:
  - Year range limits
  - Month preservation
  - Weekday preservation
- Handles full ISO datetime format with timezone

#### General Features
- Deterministic output with optional seeding
- Format-preserving obfuscation
- UTF-8 encoding support
- Comprehensive error handling
- Memory-efficient processing

#### Thread Safety
Individual obfuscator instances are NOT thread-safe. For concurrent operations:
- Create separate instances per thread
- Do not share instances across threads
- Each instance maintains its own RNG state

### Usage

```ruby
require 'obfuscator-rb'

# Text obfuscation (default :direct mode)
obfuscator = Obfuscator::Multilang.new
text = "Hello, Привет! This is a TEST текст."
result = obfuscator.obfuscate(text)
# => Each word is obfuscated using its source alphabet
# => "Idise, Кющэшэ! Izib oq g MUGU дипяд."

# Mixed mode with both alphabets
obfuscator = Obfuscator::Multilang.new(mode: :mixed)
result = obfuscator.obfuscate(text)
# => Words may contain both Latin and Cyrillic characters
# => "Fаyef, Фeфeгю! Muci лi r HЫЛO ицижё."

# With basic naturalization for more natural-looking output
obfuscator = Obfuscator::Multilang.new(mode: :mixed, naturalize: true)
result = obfuscator.obfuscate(text)
# => Output is processed to look more natural
# => "Ohеsion, Wорыой! Наvы мe л ЛУНI yeзing."

# With seed for reproducible results
obfuscator = Obfuscator::Multilang.new(seed: 12345)
result = obfuscator.obfuscate(text)
# => Same input + same seed = same output
# => "Cumic, Фяцёне! Okac ub h POWO щюзёс."

# Number obfuscation
obfuscator = Obfuscator::NumberObfuscator.new
obfuscator.obfuscate(123.45)     # => 567.89
obfuscator.obfuscate("1,234.56") # => "5,678.91"
obfuscator.obfuscate("192.168.1.1") # => "234.567.8.9"

# With configuration
obfuscator = Obfuscator::NumberObfuscator.new(
  preserve_leading_zeros: false,  # Don't keep leading zeros
  unsigned: true,                 # Remove minus signs
  seed: 12345                    # For reproducible results
)
obfuscator.obfuscate("0042")     # => "7391"
obfuscator.obfuscate("-123")     # => "456"

# Date obfuscation
obfuscator = Obfuscator::DateObfuscator.new
obfuscator.obfuscate('2024-03-15')                    # => "2025-08-23"

# Different date formats
eu = Obfuscator::DateObfuscator.new(format: :eu)      # European format
eu.obfuscate('15.03.2024')                            # => "23.08.2025"

us = Obfuscator::DateObfuscator.new(format: :us)      # US format
us.obfuscate('03/15/2024')                            # => "08/23/2025"

rus_short = Obfuscator::DateObfuscator.new(format: :rus_short) # Short format
rus_short.obfuscate('15.03.24')                       # => "23.08.25"

# With constraints
constrained = Obfuscator::DateObfuscator.new(
  format: :iso,
  constraints: {
    min_year: 2020,           # Don't generate dates before 2020
    max_year: 2025,           # Don't generate dates after 2025
    preserve_month: true,     # Keep the same month
    preserve_weekday: true    # Keep the same day of week
  }
)
constrained.obfuscate('2024-03-15')  # => "2025-03-14" (same month, same weekday)

# With seed for reproducible results
seeded = Obfuscator::DateObfuscator.new(seed: 12345)
seeded.obfuscate('2024-03-15')       # => "2025-07-21" (consistent output)
```

### Available Modes

- `:direct` (default) - preserves source language for each word
- `:eng_to_eng` - English to English only
- `:rus_to_rus` - Russian to Russian only
- `:swapped` - English to Russian and vice versa
- `:mixed` - uses both alphabets

### Available Date Presets

- `:eu` => `'%d.%m.%Y'` - European format (31.12.2023)
- `:eu_short` => `'%d.%m.%y'` - Short European format (31.12.23)
- `:rus` => `'%d.%m.%Y'` - Russian format (31.12.2023)
- `:rus_short` => `'%d.%m.%y'` - Short Russian format (31.12.23)
- `:iso` => `'%Y-%m-%d'` - ISO format (2023-12-31)
- `:us` => `'%m/%d/%Y'` - US format (12/31/2023)
- `:us_short` => `'%m/%d/%y'` - Short US format (12/31/23)
- `:iso_full` => `'%Y-%m-%dT%H:%M:%S%z'` - Full ISO format (2023-12-31T00:00:00+00:00)

### Error Handling

```ruby
begin
  obfuscator.obfuscate(text)
rescue Obfuscator::InputError => e
  # Handle invalid input types
  puts "Invalid input type: #{e.message}"
rescue Obfuscator::EncodingError => e
  # Handle encoding issues
  puts "Encoding error: #{e.message}"
rescue Obfuscator::Error => e
  # Handle other obfuscation errors
  puts "Obfuscation error: #{e.message}"
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
