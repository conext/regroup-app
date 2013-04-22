class AddDummyEntries < ActiveRecord::Migration
  def up
    App.create(app_id: 'photo_hut', app_username: 'photo_hut', app_password: 'photo_hut')
    App.create(app_id: 'file_stash', app_username: 'file_stash', app_password: 'file_stash')

    Resource.create(uri: 'http://ph.example.com/ep', local_name: 'embarrasing_photos', app: 'photo_hut', group_id: 1000)
    Resource.create(uri: 'http://ph.example.com/bp', local_name: 'blurry_photos', app: 'photo_hut', group_id: 1000)
    Resource.create(uri: 'http://fs.example.com/rd', local_name: 'random_dump', app: 'file_stash', group_id: 1000)
    Resource.create(uri: 'http://fs.example.com/wcs', local_name: 'wicked_cool_songs', app: 'file_stash', group_id: 2000)
  end

  def down
    App.where(app_id: photo_hut).first.delete
    App.where(app_id: file_stash).first.delete
    
    Resource.where(group_id: 1000).delete
    Resource.where(group_id: 2000).delete
  end
end
