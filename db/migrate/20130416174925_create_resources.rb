class CreateResources < ActiveRecord::Migration
  def up
    create_table :resources do |t|
      t.string :uri
      t.string :local_name
      t.string :group_id
      t.timestamps
    end
  end

  def down
    drop_table :resources
  end
end
