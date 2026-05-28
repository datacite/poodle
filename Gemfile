# frozen_string_literal: true

source "https://rubygems.org"

gem "rails", "~> 8.1", ">= 8.1.2.1"
gem "dotenv", "~> 3.2"
gem "oj", "~> 3.17"
gem "nokogiri", "~> 1.19", ">= 1.19.3"
gem "bolognese", "~> 2.7"
gem "maremma", ">= 5.0.0"
gem "base32-url", "~> 0.7.0" # TODO: remove soon, it is only used in one place
gem "dalli", "~> 5.0", ">= 5.0.2"
gem "lograge", "~> 0.14.0"
gem "logstash-logger", "~> 1.0"
gem "sentry-ruby", "~> 6.5"
gem "sentry-rails", "~> 6.5"
gem "jwt", "~> 3.2"
gem "cancancan", "~> 3.6", ">= 3.6.1"
gem "rack-cors", "~> 3.0"
gem "rack-utf8_sanitizer", "~> 1.11", ">= 1.11.1"
gem "next_rails", "~> 1.6"
gem 'base64', '~> 0.3.0'

group :development, :test do
  gem "binding_of_caller", "~> 2.0"
  gem "byebug", "~> 13.0", platforms: [:mri, :windows]
  gem "rubocop", "~> 1.86", ">= 1.86.2"
  gem "rubocop-performance", "~> 1.26", ">= 1.26.1"
  gem "rubocop-rails", "~> 2.35", ">= 2.35.1"
end

group :development do
  gem "listen", "~> 3.10"
  gem "spring", "~> 4.5"
  gem "spring-watcher-listen", "~> 2.1"
end

group :test do
  gem "rspec-rails", "~> 8.0", ">= 8.0.4"
  gem "capybara", "~> 3.40"
  gem "webmock", "~> 3.26", ">= 3.26.2"
  gem "vcr", "~> 6.4"
  gem "simplecov", "~> 0.22.0"
end
