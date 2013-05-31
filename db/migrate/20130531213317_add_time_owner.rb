class AddTimeOwner < ActiveRecord::Migration
  def up
    add_column :resources, :time, :string
    add_column :resources, :owner, :string
  end

  def down
    remove_column :resources, :time
    remove_column :resources, :owner
  end
end
