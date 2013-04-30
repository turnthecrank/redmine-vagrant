#!/bin/bash
# Install Redmine 2.3 on Debian Wheezy (7.0RC1).  Using packages where they are current, 
# and source where the packages are not.  
# Note: In early testing the "vagrant up" command takes 11mm 9s to create and 
#       provision this VM.

# References:
# http://www.redmine.org/projects/redmine/wiki/HowTo_Install_Redmine_210_on_Debian_Squeeze_with_Apache_Passenger

# Declare some variables specific to our site
# Revise these as needed for production use
export SHARED_FOLDER=/vagrant
export TARGET=/opt/redmine
export virtualHost=localhost

# Prep for the system lot of trouble-free package installation work 
# Update the package databases
apt-get update
# Preinject apt-get responses
cat <<EOF > /etc/apt/apt.conf.d/90forceyes
APT::Get::Assume-Yes "true";
APT::Get::force-yes "true";
EOF

# Install debconf and configure it so we can preload answers to configuration questions
apt-get install debconf-utils
# Make sure debconf does NOT ask questions if it knows the answers
cat <<EOF >/etc/sudoers.d/env_keep
Defaults	env_keep += "DEBIAN_FRONTEND"
EOF
chmod 0440 /etc/sudoers.d/env_keep
export DEBIAN_FRONTEND=noninteractive

# Install some build tools we might not need
apt-get install gcc build-essential

# Install Ruby stuff we do need
apt-get install ruby rubygems libruby libapache2-mod-passenger

# Install git stuff we need
apt-get install git

# Get the stable branch of the Redmine 2.3 source
cd /tmp
git clone https://github.com/redmine/redmine.git
cd redmine
git checkout 2.3-stable
mkdir -p $TARGET
cp -r * $TARGET

# Install development libraries (this is a lot of libraries)
apt-get install libmysqlclient-dev libmagickcore-dev libmagickwand-dev

# Install and configure MySQL Database
# Make a password for user root
mysqlRootPassword=`date +%s | sha256sum | base64 | head -c 32`
# Store the password for later reference
echo $mysqlRootPassword > $SHARED_FOLDER/mysqlRootPassword
# Rewrite a sample debconf file to ue the new password 
cp $SHARED_FOLDER/debconf-mysql-server-5.5 /tmp/
sed -e "s/thepassword/$mysqlRootPassword/;" -i /tmp/debconf-mysql-server-5.5
# Push the password response into debconf
debconf-set-selections /tmp/debconf-mysql-server-5.5
# Destroy the password file
#shred -n 3 -u  /tmp/debconf-mysql-server-5.5
# Now install the MySQL database server and clients
apt-get install mysql-server mysql-client mysql-utilities

# Create DB and user account for Redmine
# Make a mysql password for redmine
redmineDatabasePassword=`date +%s | sha256sum | base64 | head -c 32`
echo $redmineDatabasePassword > $SHARED_FOLDER/redmineDatabasePassword
# Create mysql Db and user
mysql -u root --password=$mysqlRootPassword <<EOF
CREATE DATABASE redmine CHARACTER SET utf8;
CREATE USER 'redmine'@'localhost' IDENTIFIED BY '$redmineDatabasePassword';
GRANT ALL privileges ON redmine.* TO 'redmine'@'localhost';
quit
EOF

# Configure database configuration file to tell redmine where to store stuff and how to access it
cd $TARGET/config
cp database.yml.example database.yml
sed -e "s/username: root/username: redmine/;" -i database.yml
sed -e "s/password: \"\"/password: \"$redmineDatabasePassword\"/;" -i database.yml

# Install Bundler (removing useless modules, which would otherwise create dependencies)
gem install bundler
cd $TARGET
bundle install --without development test postgresql sqlite

# Generate a session store secret
rake generate_secret_token

# Generate the database structure
RAILS_ENV=production rake db:migrate

# Generate default configuration data using the english language
RAILS_ENV=production REDMINE_LANG=en rake redmine:load_default_data

# Change database_ciphr_key: *
rake db:encrypt RAILS_ENV=production

# Create an Apache virtual host for redmine
cat > /etc/apache2/sites-available/redmine <<EOF
<VirtualHost *:80>
 ServerName $virtualHost
 DocumentRoot $TARGET/public
 <Directory $TARGET/public>
   AllowOverride all
   Options -MultiViews
 </Directory>
</VirtualHost>
EOF

# Enable the virtual host
a2ensite redmine

# Reload apache
/etc/init.d/apache2 reload
