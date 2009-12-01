class AddNestedSetToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :parent_id, :integer
    add_column :tasks, :lft, :integer
    add_column :tasks, :rgt, :integer
  end

  def self.down
    remove_column :tasks, :rgt
    remove_column :tasks, :lft
    remove_column :tasks, :parent_id
  end
end
