class CreateRegistrations < ActiveRecord::Migration
  def self.up
    create_table :registrations, :force => true do |t|
      t.integer  :event_id
      t.text     :yaml

      t.timestamps
    end
  end

  def self.down
    drop_table :registrations
  end
end
