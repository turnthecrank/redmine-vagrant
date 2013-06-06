#!/bin/bash
# install the Redmine Backlogs plugin from http://www.redminebacklogs.net

# As user root install the Redmine Git Hosting Plugin
sudo su -
# install prereqs for Ruby Gem Nokogiri
apt-get -y install libxslt-dev

mkdir -p /opt/redmine/current/plugins
cd /opt/redmine/current/plugins
git clone git://github.com/backlogs/redmine_backlogs.git
cd redmine_backlogs
git checkout v1.0.2
patch -p1 <<EOF
diff --git a/Gemfile b/Gemfile
index d37d82c..02b414f 100644
--- a/Gemfile
+++ b/Gemfile
@@ -17,7 +17,7 @@ gem 'json'
 gem "system_timer" if RUBY_VERSION =~ /^1\.8\./ && RUBY_PLATFORM =~ /darwin|linux/
 
 group :development do
-  gem "inifile"
+  gem "inifile", "~> 0.4.1" 
 end
 
 group :test do
EOF
bundle install --without development test

# Copy label files for card printing
cd /opt/redmine/current/plugins/redmine_backlogs/lib/labels
cp labels.yaml.default labels.yaml

cd /opt/redmine/current/
bundle install
RAILS_ENV=production rake redmine:plugins:migrate

# install backlogs
RAILS_ENV=production bundle exec rake redmine:backlogs:install \
   story_trackers=Bug,Support,Feature task_tracker=Task corruptiontest=false labels=true

# Restart redmine
touch /opt/redmine/current/tmp/restart.txt

# we're done being root
exit

# Follow these manual procedures in the Redmine Web interface
#
# In Administration, Plugins, Redmine Backlogs, Configure:
# * Check "Show redmine header in backlogs".
# * Adjust "Story points" as needed.
# * Check "Set story start- and duedate from sprint"
# * set "Story follows Task status" to "Loosely follow Tasks average done ratio"
# * set "Time zone for burndown day boundary" to "(GMT-5:00) Eastern..."
# * check "Enable sharing".  Set "Share new Sprints" to "With all projects"
#
# Follow the procedure titled "Creating non-accepted closed states for stories/tasks" at 
# http://www.redminebacklogs.net/en/installation.html to setting an Issue Status of 
# "In Progress" to 10% done.  This will change the status of a Story issue from "New" 
# to "In Progress".
