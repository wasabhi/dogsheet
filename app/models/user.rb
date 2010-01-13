class User < ActiveRecord::Base
  TIME_STEPS = [1, 5, 15, 30, 60]

  acts_as_authentic
  has_many :tasks
  has_many :timeslices
  
  validates_inclusion_of :time_step, :in => TIME_STEPS,
                :message => "can only be on of #{TIME_STEPS.join(',')}"
end
