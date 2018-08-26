#!/bin/bash

#bundle exec rake assets:clobber RAILS_ENV=production
bundle exec rake assets:clobber
#bundle exec rake assets:clean

#bundle exec rake assets:precompile RAILS_ENV=production
bundle exec rake assets:precompile

sudo service apache2 restart
