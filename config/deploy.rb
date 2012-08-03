require 'bundler/capistrano'

set :application, 'dragonfly-demo'
set :repository, "git@github.com:local-ch/dragonfly-demo.git"

set :user, 'railsapp'
set :deploy_via, :remote_cache
set :scm, 'git' 
set :use_sudo, false
set :scm_verbose, true
set :bundle_without,  [:development, :test, :deployment, :osx]
set :rack_env, 'production'

set :deploy_to, "/var/nginx/dragonfly-demo"
set :branch, 'master'


dev_servers = ['rails-dev01.intra.local.ch']
role :app, *dev_servers
role :web, *dev_servers

after "deploy:start", "unicorn:start"
after "deploy:stop", "unicorn:graceful_stop"
after "deploy:restart", "unicorn:restart"

namespace :unicorn do
  set :pidfile, "tmp/pids/unicorn.pid"
  set :unicorn_start, "bundle exec unicorn -c config/unicorn.rb -D"
  
  task :start, :roles => :app, :except => { :no_release => true } do 
    run "cd #{current_path} && #{unicorn_start} -E #{rack_env}"
  end
  task :stop, :roles => :app, :except => { :no_release => true } do 
    run "cd #{current_path} && kill `cat #{pidfile}`"
  end
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && kill -s QUIT `cat #{pidfile}`"
  end
  task :reload, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path}; if [ -e #{pidfile} ]; then #{try_sudo} kill -s USR2 `cat #{pidfile}`; else #{unicorn_start} -E #{rack_env}; fi"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    start
  end
end


