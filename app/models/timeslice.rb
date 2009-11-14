class Timeslice < ActiveRecord::Base
  validates_presence_of :started, :finished
  validate :finished_must_be_after_started, :if => :started_and_finished_set?

  belongs_to :task

  def duration
    finished - started
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
end
