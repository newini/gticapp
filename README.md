# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version: 3.0.0
* Rails version: 6.1.3

* System dependencies

* Configuration

* Database creation: ./db/production.sqlite3

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions


Please feel free to use a different markup language if you do not plan to run
`rake doc:app`

# 1. Full Installation
## a. Install Ruby
Install requirements.
```
sudo apt install curl
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt-get update
sudo apt-get install git-core zlib1g-dev build-essential \
    libssl-dev libreadline-dev libyaml-dev libsqlite3-dev \
    sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev \
    software-properties-common libffi-dev nodejs yarn -y

```

Install Ruby via rvenv (RuBy ENVironment).
```
cd
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec $SHELL

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
exec $SHELL

rbenv install 3.0.0
rbenv global 3.0.0
ruby -v

```
Install bundler
```
gem install bundler
```

## b. Install Rails
```
gem install rails -v 6.1.3

rbenv rehash

rails -v
# Rails 6.1.3

```

## c. Install apache2
```
sudo apt install apache2 apache2-utils -y
```

### Edit apache2 directory config (may not need?)
```
sudo vim /etc/apache2/mods-enabled/dir.conf
```
Change as like below:
```
<IfModule mod_dir.c>

    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm

</IfModule>
```

## d. Install passenger (railsをapache2で使うためのプログラム)
```
sudo apt install libcurl4-openssl-dev apache2-threaded-dev

gem install passenger

passenger-install-apache2-module
```
The command `passenger-install-apache2-module` will take about 30 min.

If it says lack of memory. Add swap.
```
sudo dd if=/dev/zero of=/swap bs=1M count=1024
sudo mkswap /swap
sudo swapon /swap
```

### Edit apache2 config
```
sudo vim /etc/apache2/apache2.conf
```
Add output of `passenger-install-apache2-module` like below. (attention! the path is depended on your user name!)
```
LoadModule passenger_module /home/your_user_name/.rbenv/versions/3.0.0/lib/ruby/gems/3.0.0/gems/passenger-6.0.7/buildout/apache2/mod_passenger.so
<IfModule mod_passenger.c>
  PassengerRoot /home/your_user_name/.rbenv/versions/3.0.0/lib/ruby/gems/3.0.0/gems/passenger-6.0.7
  PassengerDefaultRuby /home/your_user_name/.rbenv/versions/3.0.0/bin/ruby
</IfModule>
```

If you missed output of `passenger-install-apache2-module`, type `passenger-install-apache2-module --snippet` to output again.

## e. Add gticapp config (for HTTP)
```
sudo vim /etc/apache2/sites-available/gticapp.conf
```
Add below lines.
```
<VirtualHost *:80>
    ServerName gtic.jp
    ServerAlias gtic.jp
    ServerAdmin webmaster@localhost

    # !!! Be sure to point DocumentRoot to 'public'!
    DocumentRoot /var/www/html/gticapp/public

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/html/gticapp/public>
        # This relaxes Apache security settings.
        AllowOverride all

        # MultiViews must be turned off.
        Options -MultiViews

        # Uncomment this if you're on Apache >= 2.4:
        # Require all granted
    </Directory>
</VirtualHost>

```

## f. Enable HTTPS by using Let's Encrypt
Goto [Let's Encrypt](https://letsencrypt.org), followo the instuctions to enable HTTPS. It will generate new gticapp config at `/etc/apache2/sites-available/gticapp-le-ssl.conf`.


## g. Add environment variables in config
Open gticapp ssl config
```
sudo vim /etc/apache2/sites-available/gticapp-le-ssl.conf
```
Add variable name and values like below:
```
SetEnv VARIABLE_NAME some_value
```

## h. Enable gticapp site
```
# ポートを通す使うアプリ指定
sudo a2ensite gticapp

# 使わないアプリを取り除く
sudo a2dissite (gticapp以外は全部取り除く)
```

## i. Download gticapp
```
cd /var/www/html
sudo git clone https://github.com/newini/gticapp.git
sudo chown your_user_name:your_user_name gticapp
```

## j. Install gems
```
cd /var/www/html/gticapp
bundle install
```

## k. Restart apache2
```
sudo service apache2 restart
```


# 2. Useful commands to maintain
## a. bundle
Update gems on /vendor
```
bundle update
```
If you added new gems in `Gemfile`, use `bundle install` to install.


## b. Database migration
1. change db: `bin/rails g migration AddUserIdToPosts`

2. open migration file in db/migrate/2021...:
```
class AddUserIdToPosts < ActiveRecord::Migration
  def change
    ...
  end
end
```

Add like belows: `:table_name, :column_name, :type`
* `add column: `add_column :posts, :user_id, :integer, :default => false`
* `change column: `change_column :posts, :admin, :boolean, :default => false`
* `remove column: `remove_column :posts, :place, :string`


3. implement: `bin/rake RAILS_ENV=production db:migrate`
4. if want to go back: `rake db:rollback`


## c. SQLITE3
* List tables: `.tables`
* View all in a table: `select * from members;`
* View column names in a table: `pragma table_info(members);`
* Search in a table: `select * from members where last_name='...'and first_name='...';`
* Update a column in a table: `update members set gtic_flg='t' where last_name='...'and first_name='...';`
* Delete a row in a table: `DELETE FROM users WHERE id=;`


## d. Yarn (js module manager)
### d.1 Install yarn modules
The yarn module is on `package.json`. ex. `"aos": "^2.3.4"`. To install these modules, type as below command.
```
yarn install
```

### d.2 Add new yarn modules
If you want to add new js module, type
```
yarn add module_name
```

and edit `app/javascript/packs/application.js` and `app/assets/stylesheets/application.scss`.

Then, update assets by webpack as below command.
```
./bin/webpack
```

## e. npm (module manager)
### e.1 Install modules by npm
The modules are defined in `package-lock.json`.
```
npm ci
```


## f. Compile assets (may not need)
```
bundle exec rake assets:clean

bundle exec rake assets:clobber
#bundle exec rake assets:clobber RAILS_ENV=production

bundle exec rake assets:precompile
#bundle exec rake assets:precompile RAILS_ENV=production
```


# 3. about CSS and JS
## Installed
- @rails/ujs
- turbolinks
- jquery
- popper.js
- bootstrap
- aos: Animate On Scroll Library. [Documents](https://michalsnik.github.io/aos/)
- hover.css: mouse hover effects. See [documents and examples](http://ianlunn.github.io/Hover/). [How to install hover.css](https://devopspoints.com/bootstrap-4-hover.html)


## Useful links
- [css color keywords](https://www.w3.org/wiki/CSS/Properties/color/keywords)



# MEMO
```
The google-api-client gem is deprecated and will likely not be updated further.

Instead, please install the gem corresponding to the specific service to use.
For example, to use the Google Drive V3 client, install google-apis-drive_v3.
For more information, see the FAQ in the OVERVIEW.md file or the YARD docs.
```
