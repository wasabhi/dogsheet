class Timeslice < ActiveRecord::Base
  validates_presence_of :started, :finished
  validates_presence_of :user_id
  validate :finished_must_be_after_started, :if => :started_and_finished_set?
  validate :must_not_overlap, :if => :started_and_finished_set?

  belongs_to :task
  belongs_to :user

  # CSV export format
  comma do
    started :to_date => 'Date'
    started_time 'Started'
    finished_time 'Finished'
    task :name_with_ancestors => 'Task'
    hours_and_minutes 'Duration'
    decimal_hours
  end

  named_scope :by_date, lambda { |start_date,*end_date| 
    { 
      :conditions => [ 'started >= ? AND finished < ?',
      Time.zone.local(start_date.year,start_date.month,start_date.day).utc.to_s(:db), 
      end_date.first ? Time.zone.local(end_date.first.tomorrow.year,end_date.first.tomorrow.month,end_date.first.tomorrow.day).utc : Time.zone.local(start_date.tomorrow.year,start_date.tomorrow.month,start_date.tomorrow.day).utc ]
    }
  }

  named_scope :by_task_ids, lambda { |task_ids| 
    {
      :conditions => { :task_id => task_ids }
    }
  }

  named_scope :unbilled, :conditions => { :invoice_number => nil } do
    # Fetches the unbilled timeslices by task.  If deep is true, fetch
    # the timeslices for the task and all its descendants.
    def by_task(task, deep = false)
      ids = deep ? task.branch_ids : task.id
      self.find_all_by_task_id(ids)
    end
  end

  # By default, sort all finders by start time
  def self.find(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    if not options.include? :order
      options[:order] = 'started asc'
    end
    args.push(options)
    super
  end

  # Returns a sum of the total duration of an array of timeslices
  def Timeslice.total_duration(timeslices)
    timeslices.inject(0) {|total,timeslice| total += timeslice.duration}
  end

  # Duration in seconds
  def duration
    finished - started
  end

  def started_time
    self.started.to_s(:time_only)
  end

  def started_time=(started_time)
    self.started = Time.zone.parse(started_time)
  rescue ArgumentError
    @started_time_invalid = true
  end

  def finished_time
    self.finished.to_s(:time_only)
  end

  def finished_time=(finished_time)
    self.finished = Time.zone.parse(finished_time)
  rescue ArgumentError
    @finished_time_invalid = true
  end

  def date
    started.to_date
  end

  def date=(date)
    date = Date.parse(date) unless date.kind_of?(Date)
    opts = {:year => date.year, :month => date.month, :day => date.day}
    self.started = self.started.change(opts)
    self.finished = self.finished.change(opts)
  end

  # Returns the previous timeslice (for the same user)
  def previous
    Timeslice.find(:first, 
      :conditions => ["finished <= ? AND user_id = ?", started, user_id],
      :order => 'finished DESC')
  end

  # Returns the next timeslice (for the same user)
  def next
    Timeslice.find(:first, 
      :conditions => ["started >= ? AND user_id = ?", finished, user_id],
      :order => 'finished ASC')
  end

  # Compares the timeslice passed with this timeslice to see if they
  # are on the same day.
  def same_day_as?(timeslice)
    self.date == timeslice.date
  end

  # Returns the timeslice duration in minutes
  def minutes
    duration / 60
  end

  # Return the timeslice duration in hours and minutes
  def hours_and_minutes
    "%d:%02d" % [minutes / 60, minutes % 60]
  end

  # Returns the timeslice duration in decimal hours
  def decimal_hours
    ("%.2f" % [duration / 60 / 60]).to_f
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
