class TimeslicesController < ApplicationController

  # TODO Make start time configurable per user
  DAYSTART = '08:00:00'

  before_filter :require_login
  before_filter :find_task, :only => [:new]
  before_filter :find_tasks, :only => [:index,:create]
  before_filter :find_timeslice, :only => [:show, :edit, :update, :destroy]
  before_filter :set_dates, :only => [:index, :create]
  before_filter :find_timeslices, :only => [:index]
  after_filter :copy_errors, :only => [:create, :update]

  def index

    @total_duration = total_duration(@timeslices)

    # An empty timeslice for the 'Add timeslice' form
    @timeslice = Timeslice.new

    if @timeslices.length > 0
      @timeslice.started = @timeslices.last.finished
      @timeslice.task = @timeslices.last.task.parent
    else
      @timeslice.started = Time.zone.parse(@date.to_s + ' ' + DAYSTART)
    end

    @timeslice.finished = @timeslice.started + current_user.time_step.minutes

    respond_to do |format|
      format.html
      format.xml { render :xml => @timeslices }
      format.csv do
        render :csv => @timeslices, :filename => filename
      end
    end
  end

  def show

  end

  def new
    @timeslice = @task.timeslices.build
  end

  def create

    @timeslice = current_user.timeslices.new params[:timeslice]

    if params[:task] && params[:task][:name].length > 0
      unless params[:timeslice][:task_id].blank?
        parent = current_user.tasks.find(params[:timeslice][:task_id])
      end
      tasks = Task.split_and_create(params[:task][:name], parent)
      tasks.each do |task|
        task.user = current_user
        task.save
      end
      @task = tasks.last
      @timeslice.task = @task
    else
      @task = current_user.tasks.find(params[:timeslice][:task_id])
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
        @timeslices = current_user.timeslices.by_date(@date)

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
      redirect_to timesheet_url(@timeslice.date)
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

    def find_tasks
      @tasks = current_user.tasks
    end

    def find_timeslice
      @timeslice = current_user.timeslices.find(params[:id])
    end

    # Find the timeslices for a range of dates
    # FIXME Getting to comlpex, employ anonymous scopes?
    def find_timeslices
      unless params[:task_id].blank?
        # Generally, we want the timeslices for this task and all
        # its children
        ids = current_user.tasks.find(params[:task_id]).branch_ids

        if params[:date]
          @timeslices = current_user.timeslices.by_task_ids(ids).by_date @date, 
                                                                      @end_date
        else
          @timeslices = current_user.timeslices.by_task_ids(ids)
          @date = @timeslices.first.date
          # FIXME @timeslices.last throws an error here ?!
          @end_date = @timeslices[@timeslices.length - 1].date
        end
      else
        @timeslices = current_user.timeslices.by_date @date, @end_date
      end
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
      else
        @end_date = @date
      end

      # If start and end date are the same, this value should be true.
      @multiday = @date != @end_date
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

    # Return the filename for export actions.  Extension defaults to .csv
    def filename(prefix = '', extension = '.csv')
      datestr = @multiday ? "#{@date}_#{@end_date}" : "#{@date}"
      unless params[:task_id].blank?
        task = current_user.tasks.find(params[:task_id])
        prefix += task.safe_name + '-' unless task.nil?
      end
      prefix + datestr + extension
    end
end
