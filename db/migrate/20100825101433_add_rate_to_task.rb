class AddRateToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :rate, :decimal, :precision => 8, :scale => 2
  end

  def self.down
    remove_column :tasks, :rate
  end
end
