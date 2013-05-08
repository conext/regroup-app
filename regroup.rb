require 'rubygems'
require 'sinatra'
require 'sinatra/activerecord'
require 'json'

set :database, "sqlite3:///storage/regroup.db"

class Resource < ActiveRecord::Base
end

class App < ActiveRecord::Base
end

helpers do
  def find_app_with_creds(auth)
    if auth.provided?
      App.where(
        ['app_username = ? and app_password = ?', auth.credentials[0], auth.credentials[1]]
      ).first
    end
  end

  def json_re(msg)
    JSON.generate(:outcome => msg)
  end
end

before do
  @auth ||= Rack::Auth::Basic::Request.new(request.env)
  @app = find_app_with_creds(@auth)
  unless @auth.provided? and @auth.credentials and @app
    response['WWW-Authenticate'] = %(Basic realm="regroup")
    throw(:halt, [401, "Got a reservation?"])
  end
end

get '/' do
  haml :index, :format => :html5
end

get '/debug/all' do
  Resource.find(:all).each do |r|
    yield r.group_id
  end
end

get '/debug/create/:group_id' do |gid|
  Resource.create(:gid => gid)
  "#{gid}, okay."
end

get '/group/:gid/resources/?' do |gid|
  print @app.app_id
  content_type :json
  if @app.app_id == 'shindig'
    # return all
    Resource.where(['group_id = ?', gid]).to_json
  else
    # return for app
    Resource.where(['group_id = ? and app = ?', gid, @app.app_id]).to_json
  end
end

get '/group/:gid/resources/:app/?' do |gid, app|
  content_type :json
  if app == @app.app_id or @app.app_id == 'shindig'
    Resource.where(['app = ? and group_id = ?', app, gid]).to_json
  else
    json_re('you\'re not who you think you are!')
  end
end

put '/group/:gid/resources/:app' do |gid, app|
  rdata = JSON.parse(request.body)
  # check if app is allowed to create resources for :app
  # shindig - anything for any app
  # any app - only that apps resources
  if app == @app.app_id or @app.app_id == 'shindig'
    Resource.create(gid: gid, local_name: rdata['local_name'], uri: rdata['uri'], app: app)
    json_re('ok')
  else
    json_re('mind your own apps.')
  end
end
