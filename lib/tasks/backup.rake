task :backup => ["db:backup", "images:backup"]
task :restore => ["db:restore", "images:restore"]

desc "gets everything from production"
task :pull_from_prod => ["get_backup_from_production", "restore"]

task :get_backup_from_production do
  production = "stellsmi@onemanswalk.com:/users/home/stellsmi/apps/one_site/current"
  backup_dir = "log"
  db_backup, image_backup = "db-backup-latest.sql.gz", "image-backup-latest.tgz"

  FileUtils.mkdir_p backup_dir
  Dir.chdir backup_dir do
    
    FileUtils.rm db_backup if File.exists?(db_backup)
    FileUtils.rm image_backup if File.exists?(image_backup)
    
    run "scp #{File.join(production, backup_dir, db_backup)} ."
    run "scp #{File.join(production, backup_dir, image_backup)} ."
  end
end

namespace :db do
  def load_database_settings
    require 'yaml'
    settings ||= YAML::load_file("#{RAILS_ROOT}/config/database.yml")[RAILS_ENV]
    [settings['database'], settings['username'], settings['password']]
  end

  task :backup do
    puts "backing up the #{RAILS_ENV} database"

    Dir.chdir "log" do
      output = "db-backup-#{Time.now.strftime("%Y%m%d%H%M")}.sql"    

      db, user, pass = load_database_settings
      run "mysqldump -u#{user} -p#{pass} #{db} > #{output}"
      run "gzip -f #{output}"
      run "ln -s -f #{output}.gz db-backup-latest.sql.gz"
    end
  end
  
  task :restore do
    FileUtils.mkdir_p "log"
    Dir.chdir "log" do
      input = "db-backup-latest.sql.gz"
      db, user, pass = load_database_settings

      run "mysqladmin -u#{user} -p#{pass} -f drop #{db}", :ignore_errors => true
      run "mysqladmin -u#{user} -p#{pass} create #{db}"
      run "gunzip -c #{input} | mysql -u#{user} -p#{pass} #{db}"
    end
  end
end

namespace :images do
  task :backup do
    previous = Dir['log/image-backup-*.tgz'].sort[-2]
    output = File.expand_path("log/image-backup-#{Time.now.strftime("%Y%m%d%H%M")}.tgz")

    Dir.chdir "public/burn_blue/images/contacts" do
      run "tar cf - * | gzip -c > #{output}"
    end
    
    run "rm log/image-backup-latest.tgz" if File.exists?("log/image-backup-latest.tgz")
    run "cp #{output} log/image-backup-latest.tgz"
    run "rm #{previous}" if File.size(output) == File.size(previous)
  end
  
  task :restore do
    input = File.expand_path("log/image-backup-latest.tgz")

    Dir.chdir("public/burn_blue/images/contacts") do
      run "rm *"
      run "tar zxvf #{input}"
    end
  end
end
