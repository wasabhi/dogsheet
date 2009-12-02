class Task < ActiveRecord::Base
  validates_presence_of :name

  belongs_to :user
  has_many :timeslices

  acts_as_nested_set

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

  # Return the task name prefixed by the given string multiplied by the
  # tasks tree depth.
  def name_with_depth(prefix = '-')
    "#{prefix * self.level}#{self.name}"
  end

  def name_with_ancestors(separator = ':')
    if self.root?
      return self.name
    else
      return self.parent.name_with_ancestors(separator) + separator + self.name
    end
  end
end
