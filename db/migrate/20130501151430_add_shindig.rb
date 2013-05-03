class AddShindig < ActiveRecord::Migration
  def up
    App.create(app_id: 'shindig', app_username: 'shindig', app_password: 'shindig')
  end

  def down
    App.where(app_id: 'shindig').first.delete
  end
end
