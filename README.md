# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version: 2.5.1

* Rails version: '~> 4.2.11'

* System dependencies

* Configuration

* Database creation: ./db/production.sqlite3

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions


Please feel free to use a different markup language if you do not plan to run
`rake doc:app`


# Useful commands
## bundle
```
bundle install
bundle update
```

## SQL
1. change db: `bundle exec rails g migration AddUserIdToPosts`

2. open migration file:
```
class AddUserIdToPosts < ActiveRecord::Migration
  def change
    ...
  end
end
```

* add column: `add_column :posts, :user_id, :integer, :default => false`
* change column: `change_column :users, :admin, :boolean, :default => false`
* remove column: `remove_column :titles, :place, :string`


3. implement: `bundle exec rake RAILS_ENV=production db:migrate`
4. if want to go back: `rake db:rollback`


# MEMO
* sqlite 1.4.0 occurs error, install 1.3.13
