class Timeslice < ActiveRecord::Base
  validates_presence_of :started, :finished
  validates_presence_of :user_id
  validate :finished_must_be_after_started, :if => :started_and_finished_set?
  validate :must_not_overlap, :if => :started_and_finished_set?

  belongs_to :task
  belongs_to :user

  # Duration in seconds
  def duration
    finished - started
  end

  def started_time
    self.started.to_s(:time_only)
  end

  def started_time=(started_time)
    self.started = Time.parse(started_time)
  rescue ArgumentError
    @started_time_invalid = true
  end

  def finished_time
    self.finished.to_s(:time_only)
  end

  def finished_time=(finished_time)
    self.finished = Time.parse(finished_time)
  rescue ArgumentError
    @finished_time_invalid = true
  end

  private
    def started_and_finished_set?
      started && finished && !user_id.nil?
    end

    def finished_must_be_after_started
      if started >= finished
        errors.add(:finished, "must be after started time")
      end
    end

    def validate
      errors.add(:started_time, "is invalid") if @started_time_invalid
      errors.add(:finished_time, "is invalid") if @finished_time_invalid
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

      if self.user.timeslices.first(:conditions => [conditions, options])
        errors.add(:started, "overlaps with another timeslice")
      end
    end
end
