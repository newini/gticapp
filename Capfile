require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/rbenv'
set :rbenv_type, :system
set :rbenv_ruby, "2.0.0-p247"
require 'capistrano/bundler'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require "whenever/capistrano"
Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }
