class CreateTimeslices < ActiveRecord::Migration
  def self.up
    create_table :timeslices do |t|
      t.references :task
      t.timestamp :started
      t.timestamp :finished

      t.timestamps
    end
  end

  def self.down
    drop_table :timeslices
  end
end
