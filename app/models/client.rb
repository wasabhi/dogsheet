class Client < ActiveRecord::Base
  validates_presence_of :name, :email
  validates_format_of :email,
                      :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                      :message => 'must be an email address'

  has_many :tasks
end
