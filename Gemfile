# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "redis"

group :admin do
  gem "sinatra", require: false
  gem "sinatra-contrib", require: false
  gem "puma", require: false
end

group :development do
  gem "ammeter"
  gem "benchmark-ips", "~> 2.14"
  gem "concurrent-ruby-ext"
  gem "connection_pool"
  gem "cucumber"
  gem "database_cleaner-redis", "~> 2.0"
  gem "debug"
  gem "rack-test"
  gem "rake", "~> 13.3"
  gem "rantly", "~> 2.0.0"
  gem "rspec", "~> 3.13"
  gem "ruby-prof"
  gem "simplecov", "~> 0.22"
  gem "simplecov-lcov", "~> 0.8"
  gem "standard"
  gem "timecop", "~> 0.9"
end
