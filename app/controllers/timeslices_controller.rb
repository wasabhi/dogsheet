class TimeslicesController < ApplicationController
  before_filter :find_task, :only => [:new, :create]
  before_filter :find_timeslice, :only => [:show, :edit, :update, :destroy]

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
    else
      @timeslice.started = Time.now
      @timeslice.finished = Time.now
    end

    respond_to do |format|
      format.html
      format.xml { render :xml => @timeslices }
    end
  end

  def show

  end

  def new
    @timeslice = @task.timeslices.build
  end

  def create
    @timeslice = @task.timeslices.build(params[:timeslice])
    if @timeslice.save
      redirect_to timeslices_url
    else
      render :action => "new"
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
      format.html { redirect_to timeslices_path }
      format.xml  { head :ok }
    end
  end

  private
    def find_task
      @task = Task.find(params[:task_id])
    end

    def find_timeslice
      @timeslice = Timeslice.find(params[:id])
    end
end
