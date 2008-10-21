require 'yaml'

namespace :db do
  task :init do
    settings = YAML::load_file(RAILS_ROOT + "/config/database.yml")
    ["development", "test"].each do |env|
      db, user, pass = settings[env]['database'], settings[env]['username'], settings[env]['password']
      
      puts "initialize the #{env} database"
      run(%{mysql -u#{user} -p#{pass} -e "drop database if exists #{db}; create database #{db} character set utf8;"})
      run(%{rake db:migrate RAILS_ENV=#{env} --trace 2>&1})
    end
  end
end