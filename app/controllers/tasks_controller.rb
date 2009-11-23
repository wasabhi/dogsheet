class TasksController < ApplicationController

  before_filter :find_client, :only => [:index, :new]
  before_filter :find_task, :only => [:show, :edit, :update, :destroy]

  def index
    @tasks = @client.tasks
  end

  def show

  end

  def new
    @task = @client.tasks.build
  end

  def create
    @task = Task.create! params[:task]
    respond_to do |format|
      format.html { redirect_to client_url(@client) }
      format.js
    end
  end

  def edit
    
  end

  def update
    if @task.update_attributes(params[:task])
      redirect_to client_url(@task.client)
    else
      render :action => "edit"
    end
  end

  def destroy
    @client = @task.client
    @task.destroy

    respond_to do |format|
      format.html { redirect_to client_path(@client) }
      format.xml  { head :ok }
    end
  end

  private
    def find_client
      @client = Client.find(params[:client_id])
    end

    def find_task
      @task = Task.find(params[:id])
    end
end
