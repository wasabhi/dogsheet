class AddInvoiceNumberToTimeslice < ActiveRecord::Migration
  def self.up
    add_column :timeslices, :invoice_number, :string
  end

  def self.down
    remove_column :timeslices, :invoice_number
  end
end
