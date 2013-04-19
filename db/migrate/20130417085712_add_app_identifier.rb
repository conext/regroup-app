class AddAppIdentifier < ActiveRecord::Migration
  def up
    add_column :resources, :app, :string
  end

  def down
    remove_column :resources, :app
  end
end
