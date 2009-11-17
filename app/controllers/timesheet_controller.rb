class TimesheetController < ApplicationController
  def index
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
    @timeslices = Timeslice.all(:order => 'started ASC',
                    :conditions => ['started >= ? AND finished < ?',
                                    @date.to_time, @date.tomorrow.to_time])
    @timeslice = Timeslice.new
    if @timeslices.count > 0
      @timeslice.started = @timeslices.last.finished
      @timeslice.finished = @timeslices.last.finished
    end
  end
end
