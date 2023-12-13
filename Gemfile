# frozen_string_literal: true

source "https://rubygems.org"

gem "rails", "~> 5.2"
gem "dotenv"
gem "oj", ">= 2.8.3"
gem "oj_mimic_json", "~> 1.0", ">= 1.0.1"
gem "equivalent-xml", "~> 0.6.0"
gem "nokogiri", ">= 1.10.4"
gem "iso8601", "~> 0.9.0"
gem "bolognese", "~> 2.0.3"
gem "maremma", "~> 4.9.8"
gem "faraday", "~> 0.17.6"
gem "base32-url", "~> 0.5"
gem "dalli", "~> 2.7.6"
gem "lograge", "~> 0.11.2"
gem "logstash-event", "~> 1.2", ">= 1.2.02"
gem "logstash-logger", "~> 0.26.1"
gem "sentry-raven", "~> 2.9"
gem "jwt", "~> 1.5", ">= 1.5.4"
gem "cancancan", "~> 2.0"
gem "tzinfo-data", "~> 1.2017", ">= 1.2017.3"
gem "bootsnap", ">= 1.1.0", require: false
gem "rack-cors", "~> 1.0", require: "rack/cors"
gem "rack-utf8_sanitizer", "~> 1.6"
gem "git", "~> 1.5"
gem "sprockets", "~> 3.7", ">= 3.7.2"

group :development, :test do
  gem "better_errors"
  gem "binding_of_caller"
  gem "byebug", platform: :mri
  gem "rubocop", "~> 0.77.0"
  gem "rubocop-performance", "~> 1.5", ">= 1.5.1"
  gem "rubocop-rails", "~> 2.4"
end

group :development do
  gem "listen", "~> 3.0.5"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  # gem "httplog", "~> 1.0"
end

group :test do
  gem "rspec-rails", "~> 3.5", ">= 3.5.2"
  gem "capybara"
  gem "webmock", "~> 1.20.0"
  gem "vcr", "~> 3.0.3"
  gem "codeclimate-test-reporter", "~> 1.0.0"
  gem "simplecov"
end
