class Task < ActiveRecord::Base
  validates_presence_of :name

  belongs_to :user
  has_many :timeslices

  def duration
    duration = 0
    timeslices.each do |timeslice|
      duration += timeslice.duration
    end
    duration
  end

  # TODO - Repeated in Timeslice
  def hours_and_minutes
    minutes = self.duration.round / 60
    "#{minutes / 60}:#{minutes % 60}"
  end

  def decimal_hours
    self.duration / 60 / 60
  end
end
