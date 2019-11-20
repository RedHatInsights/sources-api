source 'https://rubygems.org'

plugin "bundler-inject", "~> 1.1"
require File.join(Bundler::Plugin.index.load_paths("bundler-inject")[0], "bundler-inject") rescue nil

gem 'insights-api-common', '~> 3.0'
gem 'jbuilder',             '~> 2.0'
gem 'json-schema',          '~> 2.8'
gem 'manageiq-loggers',     '~> 0.1'
gem 'manageiq-messaging',   '~> 0.1.5', :require => false
gem 'manageiq-password',    '~> 0.2', ">= 0.2.1"
gem 'more_core_extensions', '~> 3.5'
gem 'pg',                   '~> 1.0', :require => false
gem 'puma',                 '~> 3.0'
gem 'rack-cors',            '>= 1.0.4', '~> 1.0'
gem 'rails',                '~> 5.2.2'
gem 'sprockets',            '~> 4.0'

group :development, :test do
  gem 'rubocop',             '~>0.69.0', :require => false
  gem 'rubocop-performance', '~>1.3',    :require => false
  gem 'simplecov'
end

group :test do
  gem 'rspec-rails', '~>3.8'
end
