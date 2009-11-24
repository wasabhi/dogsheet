class TimeslicesController < ApplicationController
  before_filter :find_task, :only => [:new]
  before_filter :find_timeslice, :only => [:show, :edit, :update, :destroy]

  def index
    if params[:date]
      @date = Date.parse(params[:date])
    else
      @date = Date.today
    end
    @timeslices = Timeslice.all(:order => 'started ASC',
                    :conditions => ['started >= ? AND finished < ?',
                                    @date.to_time.utc, @date.tomorrow.to_time.utc])

    # An empty timeslice for the 'Add timeslice' form
    @timeslice = Timeslice.new

    if @timeslices.count > 0
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

    # This is used in the 'New task' for to set the default client.
    if @timeslices.count > 0
      @task = @timeslices.last.task.client.tasks.build
    else
      @task = Task.new
      if last_timeslice
        @task.client = last_timeslice.task.client
      end
    end

    respond_to do |format|
      format.html
      format.xml { render :xml => @timeslices }
      format.csv { send_data @timeslices.to_csv }
    end
  end

  def show

  end

  def new
    @timeslice = @task.timeslices.build
  end

  def create
    if params[:task]
      @task = Task.create! params[:task]
      @timeslice = Timeslice.new params[:timeslice]
      @timeslice.task = @task
    else
      @timeslice = Timeslice.create! params[:timeslice]
    end
    @timeslice.save
    respond_to do |format|
      format.html { redirect_to timesheet_url(@timeslice.started.to_date) }
      format.js
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
      @task = Task.find(params[:task_id])
      @task = Task.find(params[:timeslice][:task_id]) if @task.nil?
    end

    def find_timeslice
      @timeslice = Timeslice.find(params[:id])
    end
end
