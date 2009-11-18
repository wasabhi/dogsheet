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
    "%d:%02d" % [minutes / 60, minutes % 60]
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
      conditions = '(started < :started AND finished > :started) OR
                    (started < :finished AND finished > :finished) OR
                    (started > :started AND finished < :finished)'
      options = { :started => self.started, :finished => self.finished }

      # If this is not a new record, exclude self.id from the search
      unless self.new_record?
        conditions = '(' + conditions + ')' + ' AND (id != :id)'
        options.merge!(:id => self.id)
      end

      if Timeslice.first(:conditions => [conditions, options])
        errors.add(:started, "overlaps with another timeslice")
      end
    end
end
