class AddTimeStepToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :time_step, :integer, 
                {:default => '15'}
  end

  def self.down
    remove_column :users, :time_step
  end
end
