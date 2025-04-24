# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.1.5', '>= 7.1.5.1'
gem 'sprockets-rails'
# Use sqlite3 as the database for Active Record
# gem 'sqlite3', '~> 1.4'  # removed: not using a SQL database
# Use Puma as the app server (update to fix HTTP smuggling vulnerabilities)
gem 'puma', '~> 6.4.3'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Include latest Nokogiri to address XML/XSLT vulnerabilities
gem 'nokogiri', '>= 1.18.8'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# In-memory caching with Memcached
gem 'dalli'
# Required for Dalli's mem_cache_store connection pooling
gem 'connection_pool'

# In-memory caching with Memcached
gem 'dalli'
# Required for Dalli's mem_cache_store connection pooling
gem 'connection_pool'

# Weather and geocoding
gem 'geocoder'
gem 'httparty'

# Weather API clients (community gems or HTTP)
# gem 'open-weather-ruby-client' # Uncomment if you want to use the official gem

# Documentation
gem 'yard', group: %i[development test]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rspec-rails'
  gem 'webmock'
end

group :test do
  gem 'vcr'
  # Test coverage tools
  gem 'codeclimate-test-reporter', '~> 1.0.0', require: false
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '~> 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Development tools
  gem 'brakeman'
  gem 'rubocop', require: false
  # RuboCop extensions for RSpec
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'tailwindcss-rails', '~> 2.0'
