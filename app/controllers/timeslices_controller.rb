class TimeslicesController < ApplicationController
  before_filter [:find_client, :find_task]
  before_filter :find_timeslice, :only => [:show, :edit, :update, :destroy]

  def index
    @timeslices = @task.timeslices
  end

  def show

  end

  def new
    @timeslice = @task.timeslices.build
  end

  def create
    @timeslice = @task.timeslices.build(params[:timeslice])
    if @timeslice.save
      redirect_to client_task_timeslice_url(@client, @task, @timeslice)
    else
      render :action => "new"
    end
  end

  def edit
    
  end

  def update
    if @timeslice.update_attributes(params[:timeslice])
      redirect_to client_task_timeslice_url(@client, @task, @timeslice)
    else
      render :action => "edit"
    end
  end

  def destroy
    @timeslice.destroy

    respond_to do |format|
      format.html { redirect_to client_task_timeslices_path(@client, @task) }
      format.xml  { head :ok }
    end
  end

  private
    def find_client
      @client = Client.find(params[:client_id])
    end

    def find_task
      @task = @client.tasks.find(params[:task_id])
    end

    def find_timeslice
      @timeslice = @task.timeslices.find(params[:id])
    end
end
