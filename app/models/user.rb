class User < ActiveRecord::Base
  acts_as_authentic
  has_many :tasks
  has_many :timeslices

  def timeslices_by_date(start_date, end_date = nil)
    end_date = start_date unless end_date
    timeslices.find(:all, :order => 'started ASC', :conditions => [
      'started >= ? AND finished < ?',
      start_date.to_time.utc, end_date.tomorrow.to_time.utc
    ])
  end
end
