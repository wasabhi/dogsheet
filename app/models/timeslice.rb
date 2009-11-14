class Timeslice < ActiveRecord::Base
  validates_presence_of :started, :finished
  validate :finished_must_be_after_started, 
            :if => :should_compare_started_finished?

  belongs_to :task

  def duration
    finished - started
  end

  private
    def should_compare_started_finished?
      started && finished
    end

    def finished_must_be_after_started
      if started >= finished
        errors.add(:finished, "must be after started time")
      end
    end
end
