source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]


# 認証
#gem 'devise'
gem 'devise', github: 'heartcombo/devise', branch: 'ca-omniauth-2' # Use this ver. due to omniauth ver. problem
gem "omniauth", "~> 1.9.1" # Downgrade usd to attack problem. https://github.com/heartcombo/devise/issues/5236
gem 'omniauth-facebook'
gem 'recaptcha' # I am not a bot
gem 'koala' # Facebook graph api

# deviseの日本語化
gem 'devise-i18n'
gem 'devise-i18n-views'

# Graphs
gem 'chartkick' # Create beautiful JavaScript charts with one line of Ruby

# Gmail API
gem "google-api-client"

# Import xlsx file
gem "roo"

# Style
gem 'bootstrap' # Instead of "bootstrap-sass" due to old
gem "font-awesome-rails" # For Social icons
gem "jquery-rails"
gem "jquery-slick-rails"

# page
gem 'will_paginate'
gem 'will_paginate-bootstrap'



#gem 'uglifier'
#
#gem 'coffee-rails', '~> 4.2.0'
#
#gem 'therubyracer', platforms: :ruby
#gem 'bootswatch-rails'
#gem 'mandrill-api'
#
#gem 'whenever', :require => false
#
#gem 'spinjs-rails'
#gem 'config', github: 'railsconfig/config' # name changed from rails_config
#
## Depends on rails version
#gem "actionview", ">= 4.2.11"
#gem "activejob", ">= 4.2.11"
#
#gem "nokogiri", ">= 1.8.5"
#gem "rack", ">= 1.6.11"
#gem "loofah", ">= 2.2.3"
