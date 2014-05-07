source 'https://rubygems.org'

# Load environment variables.
gem 'dotenv-rails'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.1'

# Use mysql2 as the database for Active Record
gem 'mysql2'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

# Bootstrap styling.
gem 'twitter-bootstrap-rails', git: 'https://github.com/seyhunak/twitter-bootstrap-rails.git', branch: 'bootstrap3'

# Ruby Trello API.
gem 'httparty'

# Login with Google.
gem 'omniauth-google-oauth2'

# Periodic tasks.
gem 'whenever', require: false

# Pretty charts!
gem 'chartkick'

# Pretty tables!
gem 'jquery-datatables-rails', git: 'https://github.com/rweng/jquery-datatables-rails.git'
gem 'will_paginate'
gem 'jquery-ui-rails'

# Backwards-compatibility to Rail3 code. NOTE: protected-attributes must appear before delayed_jobs.
# TODO: Remove usage to these gems when dependant code is updated.
gem 'protected_attributes'

# Delayed jobs.
gem 'delayed_job_active_record'

# Poweful logging
gem 'log4r'

# SSH operations
gem 'net-ssh', require: 'net/ssh'
gem 'net-scp', require: 'net/scp'

# Command-line operations.
gem 'foreman'

# Gravatar profile pics!
gem 'gravatar_image_tag'

# Do something in every interval of time.
gem 'enat', require: false

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do
  gem 'pry-rails'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'thin'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'fakeweb'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'fakefs', :require => 'fakefs/safe'
  gem 'zeus'
end
