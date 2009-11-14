class TasksController < ApplicationController

  before_filter :find_client
  before_filter :find_task, :only => [:show, :edit, :update, :destroy]

  def index
    @tasks = Client.tasks
  end

  def show
    @task = Client.tasks.find(params[:id])
  end

  def new
    @task = @client.tasks.build
  end

  def create
    @task = @client.tasks.build(params[:task])
    if @task.save
      redirect_to client_task_url(@client, @task)
    else
      render :action => "new"
    end
  end

  def edit
    
  end

  def update
    if @task.update_attributes(params[:task])
      redirect_to client_task_url(@client, @task)
    else
      render :action => "edit"
    end
  end

  def destroy
    @task.destroy

    respond_to do |format|
      format.html { redirect_to client_tasks_path(@client) }
      format.xml  { head :ok }
    end
  end

  private
    def find_client
      @client = Client.find(params[:client_id])
    end

    def find_task
      @task = Client.tasks.find(params[:id])
    end
end
