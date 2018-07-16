source 'https://rubygems.org'

gem 'rails' , '~> 4.0.0'
gem 'sqlite3'
gem 'sass-rails' , '~> 4.0'
gem 'uglifier', '~> 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 1.2'
gem 'therubyracer', platforms: :ruby
gem 'bcrypt', '~> 3.1.2'
#gem 'bcrypt-ruby', '~> 3.1.2'
gem 'bootstrap-sass'
gem 'bootswatch-rails'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'mandrill-api'
gem 'koala'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'whenever', :require => false
gem 'chartkick'
gem 'spinjs-rails'
gem 'config', github: 'railsconfig/config' # name changed from rails_config

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'rspec-rails'
  gem 'guard-rspec' # , '2.5.0' due to error
  gem 'spork-rails'
  gem 'guard-spork'
  gem 'childprocess'
  gem "capistrano-bundler"
  gem "capistrano-rails"
  gem "capistrano-rbenv"
  gem 'quiet_assets' 
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'factory_girl_rails'
end

group :production do
#  gem 'rails_12factor'
end
