source 'https://rubygems.org'

jruby_jars_version = '9.2.5.0'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.2.1' 
# Use jdbcsqlite3 as the database for Active Record
gem 'activerecord-jdbcsqlite3-adapter'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# The Ruby Rhino does not support ES6 must lock autoprefixer-rails to 8.6.0 (even 8.6.5 fails)
gem 'therubyrhino', platform: :jruby
gem 'autoprefixer-rails', '8.6.0', platform: :jruby
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
gem 'devise-i18n'

# Using HAML
gem 'hamlit'

# Using Bootstrap
gem 'jquery-rails'
gem 'popper_js'
gem 'bootstrap', '~> 4.1.2' 
# gem "bootstrap", ">= 4.3.1" #depends on auto-prefixer which requires node

# Pagination
gem 'pagy', '~> 2.1.1'

# Markdown
gem 'kramdown'

# Console
gem 'pry'

# Font Awesome
gem 'font-awesome-sass'

# For CSV importing and exporting
gem 'smarter_csv', require: false
gem 'cmess', require: false, git: 'https://github.com/rebelwarrior/cmess.git'
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
  gem 'rubocop', '~> 0.60.0', require: false
  gem 'rubocop-rspec', require: false
  # Code smell checker 
  gem 'reek', require: false 
end

group :deploy do
  # For Warbler see: config/application.rb and config/environtments/production.rb
  gem 'warbler', require: false, platforms: :jruby
  gem 'jruby-jars', jruby_jars_version, require: false, platforms: :jruby
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

## Security Vulnerability on previous versions
gem 'sprockets', '>= 3.7.2', '< 4.0.0' #'>= 4.0.0.beta8'


## Internationalization Bug with 1.3.0 & JRuby - locking to 1.2
gem 'i18n', '~> 1.2.0'
