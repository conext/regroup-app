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

before '/group/*' do
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

get '/group/:gid/resources/?' do |gid|
  print @app.app_id
  content_type :json
  if @app.app_id == 'shindig'
    # return all
    Resource.where(['group_id = ?', gid]).to_json
  else
    # return for app
    # TODO: one-off demo hack, rework this when the sea is calm.
    if @app.app_id == 'wordpress'
      Resource.where(['group_id = ? and app = "https%3A%2F%2Fwordpress-widget.identitylabs.org%2Fwidget.xml"', gid]).to_json
    else
      Resource.where(['group_id = ? and app = ?', gid, @app.app_id]).to_json
    end 
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

put '/group/:gid/resources/:app/?' do |gid, app|
  rdata = JSON.parse(request.body.read)
  # check if app is allowed to create resources for :app
  # shindig - anything for any app
  # any app - only that apps resources
  if app == @app.app_id or @app.app_id == 'shindig'
    if Resource.where(['local_name = ? and uri = ? and app = ?', rdata['local_name'], rdata['uri'], app]).first.nil?
      Resource.create(group_id: gid, local_name: rdata['local_name'], uri: rdata['uri'], app: app, time: rdata['time'], owner: rdata['owner'])
      status 201
      json_re('ok')
    else
      status 409
      json_re('error')
    end
  else
    json_re('mind your own apps.')
  end
end

delete '/group/:gid/resources/:app/?' do |gid, app|
  rdata = JSON.parse(request.body.read)
  if app == @app.app_id or @app.app_id == 'shindig'
    Resource.where(['local_name = ?', rdata['local_name']]).first.delete
    json_re('obliterated')
  else
    json_re('mind your own apps.')
  end
end
