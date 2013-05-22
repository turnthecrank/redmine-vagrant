# roles/redmine.rb
name "redmine"
description "Redmine box to manage development process"
run_list(
  "recipe[apt]",
  "recipe[apache2]",
  "recipe[passenger_apache2]",
  "recipe[mysql::server]",
  "recipe[database::mysql]",
  "recipe[chefGemMysql]",
  "recipe[redmine]",
  "recipe[gitolite]",
  "recipe[gitoliteUser]"
)

default_attributes(
  "redmine" => {
    "databases" => {
      "production" => {
        "password" => "redmine_password",
        "adapter"  => "mysql2"
      }
    },
    "revision" => "2.3.1"
  },
  "mysql" => {
    "server_root_password"   => "supersecret_password",
    "server_repl_password"   => "iloverandompasswordsbutthiswilldo",
    "server_debian_password" => "iloverandompasswordsbutthiswilldo"
  }
)
