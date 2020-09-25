source 'https://rubygems.org'

plugin "bundler-inject", "~> 1.1"
require File.join(Bundler::Plugin.index.load_paths("bundler-inject")[0], "bundler-inject") rescue nil

gem 'cloudwatchlogger',     '~> 0.2.1'
gem 'insights-api-common',  '~> 4.0'
gem 'jbuilder',             '~> 2.0'
gem 'json-schema',          '~> 2.8'
gem 'manageiq-loggers',     '~> 0.4', ">= 0.4.2"
gem 'manageiq-messaging',   '~> 0.1.6', :require => false
gem 'manageiq-password',    '~> 0.2', ">= 0.2.1"
gem 'more_core_extensions', '~> 3.5'
gem 'pg',                   '~> 1.0', :require => false
gem 'puma',                 '~> 4', '>= 4.3.5'
gem 'rack-cors',            '>= 1.1.1', '~> 1.1'
gem 'rails',                '~> 5.2.2'
gem 'sprockets',            '~> 4.0'

group :development, :test do
  gem 'rubocop',             '~>0.69.0', :require => false
  gem 'rubocop-performance', '~>1.3',    :require => false
  gem 'simplecov', '~> 0.17.1'
end

group :test do
  gem "factory_bot_rails"
  gem 'rspec-rails', '~>3.8'
  gem 'webmock'
end
