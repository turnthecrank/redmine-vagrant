# --- Install packages we need ---

chef_gem 'mysql' do
  action :nothing
end.run_action(:install)

chef_gem 'mysql2' do
  action :nothing
end.run_action(:install)
