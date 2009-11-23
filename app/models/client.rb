class Client < ActiveRecord::Base
  validates_presence_of :name, :email
  validates_format_of :email,
                      :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                      :message => 'must be an email address'

  has_many :tasks

  def shortcode
    words =  self.name.split
    shortcode = ''
    if words.count > 1
      words[0..3].each do |w|
        shortcode += w.first.upcase
      end
    else
      shortcode = self.name[0..3].upcase
    end
    shortcode
  end
end
