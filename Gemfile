source 'https://rubygems.org'

jruby_jars_version = '9.2.0.0'

TODO = "Switch will paginate w/ kaminari or pagy"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
# Use jdbcsqlite3 as the database for Active Record
gem 'activerecord-jdbcsqlite3-adapter'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyrhino'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'listen', platforms: :jruby

# Devise for User Login
gem 'devise'

# Using HAML
gem 'haml', platforms: :jruby
gem 'hamlit', platforms: :ruby

# Using Bootstrap
gem 'jquery-rails'
gem 'popper_js'
gem 'bootstrap', '~> 4.0.0.beta3'

# Pagination
# gem 'will_paginate' # , '~> 3.0.7'
# gem 'bootstrap-will_paginate'
gem 'pagy'

# Markdown
gem 'kramdown'

# Console
gem 'pry'

# Font Awesome
gem 'font-awesome-sass'

# For CSV importing and exporting
gem 'smarter_csv', require: false # , '~> 1.0.19' #1.0.19 is out...
gem 'cmess', require: false # , '~> 0.4.1'
gem 'celluloid', '~> 0.17.3', require: false
gem 'sucker_punch', require: false

# For Roles and Authorization
gem 'action_policy'

group :development, :test do
  # RSpec (testing)
  gem 'rspec-rails'
  gem 'factory_bot'
  # Capybara (feature testing)
  gem 'capybara'
  # RuboCop for stylechecker
  gem 'rubocop', '~> 0.49.1', require: false
  gem 'rubocop-rspec', require: false
end

group :deploy do
  # For Warbler see: config/application.rb and config/environtments/production.rb
  gem 'warbler', require: false, platforms: :jruby
  gem 'jruby-jars', jruby_jars_version, require: false, platforms: :jruby
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
