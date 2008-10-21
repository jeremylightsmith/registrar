class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :name
      t.string :url_name
      t.integer :user_id
      t.text :columns_as_yaml

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
