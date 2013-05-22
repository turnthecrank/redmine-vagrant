#!/bin/bash
# This script assumes gitolite was installed as user git with homedir /var/lib/git 
# and a key copied from /var/www/.ssh/redmine_gitolite_admin_id_rsa.pub 

# As user root install the Redmine Git Hosting Plugin
sudo su -
mkdir -p /opt/redmine/current/plugins
cd /opt/redmine/current/plugins
git clone https://github.com/jbox-web/redmine_git_hosting.git
cd redmine_git_hosting
git checkout 0.6.1
gem install bundler
bundle install

cd /opt/redmine/current
RAILS_ENV=production rake redmine:plugins:migrate 
rake redmine_git_hosting:install_scripts RAILS_ENV=production WEB_USER=www-data

# Make the plugin scratch directory and adjust access to www-data (aka Redmine) can use it.
mkdir -p /tmp/redmine_git_hosting
chown -R www-data /tmp/redmine_git_hosting

# Restart redmine
touch /opt/redmine/current/tmp/restart.txt

# we're done being root
exit

