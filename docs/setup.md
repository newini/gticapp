
## Set enviroment variables

### in server
Open apache file `sudo vim /etc/apache2/sites-enabled/gticapp-le-ssl.conf`
and add variables
```
<VirtualHost hostname:80>
   ...
   <SetEnv VARIABLE_NAME variable_value>
# Set gtic environment variable
   SetEnv MAIL_ADDRESS
   SetEnv MAIL_DOMAIN
   SetEnv MAIL_PORT
   SetEnv MAIL_USER_NAME
   SetEnv MAIL_PASSWORD
   ...
</VirtualHost>
```
then reload `sudo service restart apache2`

### in Rails
Open rb file `vim config/environments/production.rb`, `vim app/mailers/invitation_mailer.rb`
and add `ENV['MAIL_ADDRESS']`
