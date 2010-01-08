class Task < ActiveRecord::Base
  validates_presence_of :name

  belongs_to :user
  has_many :timeslices, :dependent => :destroy

  acts_as_nested_set

  def duration
    duration = 0
    timeslices.each do |timeslice|
      duration += timeslice.duration
    end
    duration
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
