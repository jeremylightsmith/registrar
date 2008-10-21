set :application, "one_site"
set :user, "stellsmi"

set :repository,  "http://onemanswalk.com/svn/projects/#{application}"
set :home, "/users/home/stellsmi"
set :deploy_to, "#{home}/apps/#{application}"

role :app, "onemanswalk.com"
role :web, "onemanswalk.com"
role :db,  "onemanswalk.com", :primary => true

deploy.task :after_symlink do
  run "ln -nfs #{home}/apps/rails-2.0.1 #{current_path}/vendor/rails"
  run "ln -nfs #{shared_path}/contacts #{current_path}/public/burn_blue/images/contacts" 
  run "ln -nfs #{shared_path}/log #{current_path}/public/log" 
end

deploy.task :restart do
  run "kill `cat #{home}/var/run/fcgi-#{application}.pid`"
end

deploy.task :start do
end

deploy.task :backup do
  run "cd #{current_path} && rake backup RAILS_ENV=production"
end