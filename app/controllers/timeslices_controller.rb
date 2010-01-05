class TimeslicesController < ApplicationController
  before_filter :require_login
  before_filter :find_task, :only => [:new]
  before_filter :find_timeslice, :only => [:show, :edit, :update, :destroy]
  before_filter :set_dates, :only => [:index, :create]
  after_filter :copy_errors, :only => [:create, :update]

  def index

    @timeslices = current_user.timeslices_by_date @date, @end_date

    # An empty timeslice for the 'Add timeslice' form
    @timeslice = Timeslice.new

    @total_duration = total_duration(@timeslices)

    if @timeslices.length > 0
      last_timeslice = @timeslices.last
      @timeslice.started = @timeslices.last.finished
      @timeslice.finished = @timeslices.last.finished + 15.minutes
      @timeslice.task = @timeslices.last.task
    else
      last_timeslice = Timeslice.last
      @timeslice.started = Time.parse(@date.to_s + ' 08:00:00')
      @timeslice.finished = @timeslice.started + 15.minutes
      if last_timeslice
        @timeslice.task = last_timeslice.task
      end
    end

    @tasks = Task.find_all_by_user_id(current_user.id, :order => "lft")
    @task = current_user.tasks.build

    respond_to do |format|
      format.html
      format.xml { render :xml => @timeslices }
      format.csv do
        if @date == @end_date
          filename = "#{@date}.csv"
        else
          filename = "#{@date}_#{@end_date}.csv"
        end
        response.headers['Content-Type'] = 'text/csv; charset=UTF8; header=present'
        response.headers['Content-Disposition'] = 'attachment;filename=' + filename
      end
    end
  end

  def show

  end

  def new
    @timeslice = @task.timeslices.build
  end

  def create
    if params[:task]
      @task = current_user.tasks.create params[:task]
      @timeslice = current_user.timeslices.new params[:timeslice]
      @timeslice.task = @task
    else
      if params[:task_id]
        @task = current_user.tasks.find(params[:task_id])
      else
        @task = current_user.tasks.find(params[:timeslice][:task_id])
      end
      @timeslice = current_user.timeslices.new params[:timeslice]
    end

    # If date was passed explicitly, make sure the timeslice is set
    # to this date.  This is for entry formats which have time only
    # input fields, in which case the date will be an extra parameter
    if params[:date]
      @timeslice.date = @date
    end

    # When using the AJAX create, it may be necessary to insert the timeslice
    # before an existing timeslice on the current day view.  Set up a
    # variable containing the next timeslice if the date is the same as the
    # timeslice being created.
    if @timeslice.next && @timeslice.next.same_day_as?(@timeslice)
      @next = @timeslice.next
    end

    respond_to do |format|
      if @timeslice.save
        # The AJAX create also needs an array of timeslices for the day to
        # update the time summary in the header
        @timeslices = current_user.timeslices_by_date(@date)

        format.html { redirect_to timesheet_url(@timeslice.started.to_date) }
        format.js
      else
        @timeslice.errors.add(:started_time,@timeslice.errors.on(:started)) if @timeslice.errors.on(:started)
        @timeslice.errors.add(:finished_time,@timeslice.errors.on(:finished)) if @timeslice.errors.on(:finished)
        format.html { render :action => 'new' }
        format.js { render :partial => 'errors' }
      end
    end
  end

  def edit
    
  end

  def update
    if @timeslice.update_attributes(params[:timeslice])
      redirect_to timeslice_url(@timeslice)
    else
      render :action => "edit"
    end
  end

  def destroy
    date = @timeslice.started.to_date
    @timeslice.destroy

    respond_to do |format|
      format.html { redirect_to timesheet_path(date) }
      format.xml  { head :ok }
      format.js
    end
  end

  private
    def find_task
      @task = current_user.tasks.find(params[:task_id])
      @task = current_user.tasks.find(params[:timeslice][:task_id]) if @task.nil?
    end

    def find_timeslice
      @timeslice = current_user.timeslices.find(params[:id])
    end

    def set_dates
      # If no date was passed, set today by default
      if params[:date]
        @date = Date.parse(params[:date])
      else
        @date = Date.today
      end

      # If no end date was passed, make the same as start date
      if params[:end_date]
        @end_date = Date.parse(params[:end_date])
        @multiday = true
      else
        @end_date = @date
        @multiday = false
      end
    end

    # The error messages for the native started and finished attributes
    # need to be copied to the started_time and finsihed_time attributes
    # if they are present.
    def copy_errors
      @timeslice.errors.add(:started_time,@timeslice.errors.on(:started)) if @timeslice.errors.on(:started_at)
      @timeslice.errors.add(:finished_time,@timeslice.errors.on(:finished)) if @timeslice.errors.on(:finished_at)
    end

    # Return the sum duration of a set of timeslices
    def total_duration(timeslices)
      timeslices.inject(0) do |total, timeslice|
         total + timeslice.duration
      end
    end
end
