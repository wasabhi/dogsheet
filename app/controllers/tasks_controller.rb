class TasksController < ApplicationController

  before_filter :find_task, :only => [:show, :edit, :update, :destroy]
  before_filter :find_sub_tasks, :only => [:show]
  before_filter :find_all_tasks, :only => [:index, :edit, :update, :destroy]
  before_filter :empty_task, :only => [:index]

  def index
    @tasks = current_user.tasks.roots
  end

  def show

  end

  def new
    @task = current_user.tasks.build
  end

  def create
    @task = Task.new params[:task]
    @task.user = current_user
    respond_to do |format|
      if @task.save
        @tasks = current_user.tasks.roots
        flash[:notice] = 'Task added';

        format.html do
          redirect_to @task.root? ? tasks_url : task_url(@task.parent)
        end
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

    def find_sub_tasks
      @sub_tasks = @task.children
    end

    def find_all_tasks
      @tasks = Task.find_all_by_user_id(current_user.id, :order => 'lft')
    end

    def empty_task
      @task = Task.new
    end
end
