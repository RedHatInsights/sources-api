source 'https://rubygems.org'

gem 'jbuilder',           '~> 2.0'
gem 'json-schema',        '~> 2.8'
gem 'manageiq-loggers',   '~> 0.1'
gem 'manageiq-messaging', '~> 0.1.2', :require => false
gem 'manageiq-password',  '~> 0.2', ">= 0.2.1"
gem 'pg',                 '~> 1.0', :require => false
gem 'puma',               '~> 3.0'
gem 'rack-cors',          '>= 0.4.1'
gem 'rails',              '~> 5.2.2'

gem 'inventory_refresh', :git => 'https://github.com/ManageIQ/inventory_refresh', :branch => 'master'
gem 'manageiq-api-common', :git => 'https://github.com/ManageIQ/manageiq-api-common', :branch => 'master'
gem 'topological_inventory-core', :git => 'https://github.com/ManageIQ/topological_inventory-core', :branch => 'master'

group :development, :test do
  gem 'simplecov'
end

group :test do
  gem 'rspec-rails', '~>3.8'
end

#
# Custom Gemfile modifications
#
# To develop a gem locally and override its source to a checked out repo
#   you can use this helper method in bundler.d/*.rb e.g.
#
# override_gem 'topological_inventory-core', :path => "../topological_inventory-core"
#
def override_gem(name, *args)
  if dependencies.any?
    raise "Trying to override unknown gem #{name}" unless (dependency = dependencies.find { |d| d.name == name })
    dependencies.delete(dependency)

    calling_file = caller_locations.detect { |loc| !loc.path.include?("lib/bundler") }.path
    calling_dir  = File.dirname(calling_file)

    args.last[:path] = File.expand_path(args.last[:path], calling_dir) if args.last.kind_of?(Hash) && args.last[:path]
    gem(name, *args).tap do
      warn "** override_gem: #{name}, #{args.inspect}, caller: #{calling_file}" unless ENV["RAILS_ENV"] == "production"
    end
  end
end

# Load other additional Gemfiles
#   Developers can create a file ending in .rb under bundler.d/ to specify additional development dependencies
Dir.glob(File.join(__dir__, 'bundler.d/*.rb')).each { |f| eval_gemfile(File.expand_path(f, __dir__)) }
