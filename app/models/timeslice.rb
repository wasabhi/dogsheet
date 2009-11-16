class Timeslice < ActiveRecord::Base
  validates_presence_of :started, :finished
  validate :finished_must_be_after_started, :if => :started_and_finished_set?
  validate :must_not_overlap, :if => :started_and_finished_set?

  belongs_to :task

  # Duration in seconds
  def duration
    finished - started
  end

  # Duration as a string in hours and minutes
  def hours_and_minutes
    minutes = self.duration.round / 60
    "#{minutes / 60}:#{minutes % 60}"
  end

  def decimal_hours
    self.duration / 60 / 60
  end

  private
    def started_and_finished_set?
      started && finished
    end

    def finished_must_be_after_started
      if started >= finished
        errors.add(:finished, "must be after started time")
      end
    end

    def must_not_overlap
      # TODO 3 queries here, should be cut down
      if Timeslice.first(:conditions => ['started <= ? AND finished >= ?',
                                        self.started, self.started])
        errors.add(:started, "overlaps with the end of another timeslice")
      end
      if Timeslice.first(:conditions => ['started <= ? AND finished >= ?',
                                        self.finished, self.finished])
        errors.add(:started, "overlaps with the start of another timeslice")
      end
      if Timeslice.first(:conditions => ['started >= ? AND finished <= ?',
                                        self.started, self.finished])
        errors.add(:started, "overlaps with the start of another timeslice")
      end
    end
end
