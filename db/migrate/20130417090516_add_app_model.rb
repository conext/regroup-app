class AddAppModel < ActiveRecord::Migration
  def up
    create_table :apps do |t|
      t.string :app_id
      t.string :app_username
      t.string :app_password
      t.timestamps
    end
  end

  def down
    drop_table :apps
  end
end
