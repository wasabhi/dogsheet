class TasksController < ApplicationController

  before_filter :find_task, :only => [:show, :edit, :update, :destroy]

  def index
    @tasks = current_user.tasks
  end

  def show

  end

  def new
    @task = current_user.tasks.build
  end

  def create
    @task = Task.new params[:task]
    @task.user = current_user
    @tasks = current_user.tasks
    respond_to do |format|
      if @task.save
        flash[:notice] = 'Task added';
        format.html { redirect_to tasks_url }
        format.js
      else
        format.html { render :action => 'new' }
        format.js { render :partial => 'errors' }
      end
    end
  end

  def edit
    
  end

  def update
    if @task.update_attributes(params[:task])
      redirect_to tasks_url
    else
      render :action => "edit"
    end
  end

  def destroy
    @task.destroy

    respond_to do |format|
      format.html { redirect_to tasks_url }
      format.xml  { head :ok }
    end
  end

  private
    def find_task
      @task = current_user.tasks.find(params[:id])
    end
end
