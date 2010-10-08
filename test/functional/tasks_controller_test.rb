require 'test_helper'

class TasksControllerTest < ActionController::TestCase
  
  def setup
    activate_authlogic
  end

  test "should redirect index if logged out" do
    get :index
    assert_redirected_to new_user_session_url
  end

  test "should get index" do
    UserSession.create(users(:one))
    get :index
    assert_response :success
    assert_not_nil assigns(:tasks)
    assert_equal 2, assigns(:tasks).length
    assert_not_nil assigns(:task)
  end

  test "should redirect show if logged out" do
    get :show, :id => tasks(:one).id
    assert_redirected_to new_user_session_url
  end

  test "should show task" do
    UserSession.create(users(:one))
    get :show, :id => tasks(:one).id
    assert_response :success
    assert_not_nil assigns(:task)
    assert_equal assigns(:task).id, tasks(:one).id
  end

  test "should show task with no timeslices" do
    UserSession.create(users(:one))
    get :show, :id => tasks(:four).id
    assert_response :success
    assert_not_nil assigns(:task)
    assert_equal assigns(:task).id, tasks(:four).id
  end

  test "should not show another users task" do
    UserSession.create(users(:one))
    get :show, :id => tasks(:two).id
    assert_response :missing
  end

  test "redirect new if logged out" do
    get :new
    assert_redirected_to new_user_session_url
  end

  test "should get new" do
    UserSession.create(users(:one))
    get :new
    assert_response :success
  end

  test "should redirect create if logged out" do
    post :create, :task => { :name => 'Test task' }
    assert_redirected_to new_user_session_url
  end

  test "should create task" do
    UserSession.create(users(:one))
    assert_difference('Task.count') do
      post :create, :task => { :name => 'Test task' }
    end
    assert_redirected_to tasks_url
  end

  test "should create sub task" do
    UserSession.create(users(:one))
    assert_difference('Task.count') do
      post :create, :task => { :name => 'Test task', :parent_id => tasks(:one).id }
    end
    assert_redirected_to task_url(tasks(:one))
  end

  test "should redirect edit if logged out" do
    get :edit, :id => tasks(:one).id
    assert_redirected_to new_user_session_url
  end

  test "should get edit" do
    UserSession.create(users(:one))
    get :edit, :id => tasks(:one).id
    assert_response :success
    assert_not_nil assigns(:task)
    assert_not_nil assigns(:tasks)
  end

  test "should not edit another users task" do
    UserSession.create(users(:one))
    get :edit, :id => tasks(:two).id
    assert_response :missing
  end

  test "should redirect update if logged out" do
    put :update, :id => tasks(:one).id, :task => { :name => 'Test task'}
    assert_redirected_to new_user_session_url
  end

  test "should update task" do
    UserSession.create(users(:one))
    put :update, :id => tasks(:one).id, :task => { :name => 'Test task'}
    assert_redirected_to tasks_url
  end

  test "should not update another users task" do
    UserSession.create(users(:one))
    put :update, :id => tasks(:two).id, :task => { :name => 'Test task'}
    assert_response :missing
  end

  test "should redirect destroy if logged out" do
    delete :destroy, :id => tasks(:one).id
    assert_redirected_to new_user_session_url
  end

  test "should destroy task" do
    UserSession.create(users(:one))
    assert_difference('Task.count', -1) do
      delete :destroy, :id => tasks(:one).id
    end
  end

  test "should get unbilled timeslices" do
    stub_xero_requests
    UserSession.create(users(:two))
    get :unbilled, :id => tasks(:two).id
    assert_response :success
    assert_equal tasks(:two), assigns(:task)
    assert_equal 3, assigns(:timeslices).length
    assert_equal 32, assigns(:contacts).length
    assert_equal 3, assigns(:accounts).length
  end

  test "should get unbilled timeslices for task without rate" do
    stub_xero_requests
    UserSession.create(users(:one))
    get :unbilled, :id => tasks(:one).id
    assert_response :success
    assert_equal tasks(:one), assigns(:task)
    assert_equal 2, assigns(:timeslices).length
  end

  test "should generate an invoice" do
    stub_xero_requests
    UserSession.create(users(:two))
    assert_difference 'Timeslice.unbilled.count', -2 do
      get :invoice, :id => tasks(:two).id,
        :timeslice_ids => tasks(:two).timeslices.map(&:id),
        :date => '2010-01-01', :due_date => '2010-02-20'
      assert assigns(:task)
      assert_equal Date.parse('2010-01-01'), assigns(:date)
      assert_equal Date.parse('2010-02-20'), assigns(:due_date)
      assert_equal 2, assigns(:timeslices).count
    end
  end

  test "should set default dates when generating an invoice" do
    stub_xero_requests
    UserSession.create(users(:two))
    get :invoice, :id => tasks(:two).id,
      :timeslice_ids => tasks(:two).timeslices.map(&:id)
    assert_equal Date.today, assigns(:date)
    assert_equal Date.today + 30.days, assigns(:due_date)
  end

  test "should redirect to xero on invalid token" do
    stub_xero_requests_with_token_expired
    UserSession.create(users(:one))
    get :unbilled, :id => tasks(:one).id
    assert_equal unbilled_task_path(tasks(:one)), session[:xero_redirect_to]
    assert_redirected_to :controller => 'xero_sessions', :action => 'new'
  end
end
