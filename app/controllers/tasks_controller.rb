class TasksController < ApplicationController

  before_filter :find_task, :only => [
    :show, :edit, :update, :destroy, :unbilled, :invoice
  ]
  before_filter :find_sub_tasks, :only => [:show]
  before_filter :find_all_tasks, :only => [:index, :edit, :update, :destroy]
  before_filter :empty_task, :only => [:index]
  before_filter :get_xero_gateway, :only => [:unbilled, :invoice]
  before_filter :check_xero_tokens, :only => [:unbilled, :invoice]

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

  def unbilled
    @date = params[:date] || Date.today
    @due_date = params[:due_date] || Date.today + 30
    @contacts = @xero_gateway.get_contacts.contacts.select do |contact|
      contact.is_customer
    end
    @accounts = @xero_gateway.get_accounts_list.find_all_by_type('REVENUE')
    @timeslices = @current_user.timeslices.unbilled.by_task(@task, true)
    @total_hours = @timeslices.inject(0.00) do |total,timeslice|
      total += timeslice.decimal_hours
    end
    @total_invoice_price = @timeslices.inject(0.00) do |total,timeslice|
      total += timeslice.cost
    end
  end

  def invoice
    if params[:date].blank?
      @date = Date.today
    else
      @date = Date.parse(params[:date])
    end

    if params[:due_date].blank?
      @due_date = @date + 30.days
    else
      @due_date = Date.parse(params[:due_date])
    end

    @timeslices = @current_user.timeslices.find(params[:timeslice_ids])
    @invoice = @task.create_xero_invoice(@xero_gateway, params[:contact],
                                         @timeslices, params[:account_code],
                                         @date, @due_date,
                                         params[:line_amount_types])
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
