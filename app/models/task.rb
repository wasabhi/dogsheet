class Task < ActiveRecord::Base
  validates_presence_of :name

  belongs_to :client
  has_many :timeslices

  def duration
    duration = 0
    timeslices.each do |timeslice|
      duration += timeslice.duration
    end
    duration
  end
end
