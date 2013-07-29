require './regroup'
require 'sinatra/activerecord/rake'

namespace :admin do
  desc "Create credentials for a new application."
  task :register_app do
    if ENV['APP_ID'].nil? or ENV['APP_USERNAME'].nil? or ENV['APP_PASSWORD'].nil? 
      puts "Run it like this:"
      puts "$ rake admin:register_app APP_ID=<coolapp> APP_USERNAME=<coolapp> APP_PASSWORD=<appisawesome>"
      abort("Missing parameters.")
    end

    app = App.create(app_id: ENV['APP_ID'], app_username: ENV['APP_USERNAME'], app_password: ENV['APP_PASSWORD']) 
    if app
      puts "Created!"
    else
      puts "Something went wrong. Maybe the app already exists?"
    end

  end
end
