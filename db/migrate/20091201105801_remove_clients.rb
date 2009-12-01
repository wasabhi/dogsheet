class RemoveClients < ActiveRecord::Migration
  def self.up
    remove_column :tasks, :client_id
    drop_table :clients
  end

  def self.down
    add_column :tasks, :client_id, :integer
    create_table "clients" do |t|
      t.string   "name"
      t.string   "email"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
