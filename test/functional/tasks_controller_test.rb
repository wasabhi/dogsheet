require 'test_helper'

class TasksControllerTest < ActionController::TestCase
  
  setup :activate_authlogic

  def test_should_redirect_index_if_logged_out
    get :index
    assert_redirected_to new_user_session_url
  end

  def test_should_get_index
    UserSession.create(users(:one))
    get :index
    assert_response :success
    assert_not_nil assigns(:tasks)
    assert_equal 2, assigns(:tasks).length
  end

  def test_should_redirect_show_if_logged_out
    get :show, :id => tasks(:one).id
    assert_redirected_to new_user_session_url
  end

  def test_should_show_task
    UserSession.create(users(:one))
    get :show, :id => tasks(:one).id
    assert_response :success
    assert_not_nil assigns(:task)
    assert_equal assigns(:task).id, tasks(:one).id
  end

  def test_should_not_show_another_users_task
    UserSession.create(users(:one))
    get :show, :id => tasks(:two).id
    assert_response :missing
  end

  def test_redirect_new_if_logged_out
    get :new
    assert_redirected_to new_user_session_url
  end

  def test_should_get_new
    UserSession.create(users(:one))
    get :new
    assert_response :success
  end

  def test_should_redirect_create_if_logged_out
    post :create, :task => { :name => 'Test task' }
    assert_redirected_to new_user_session_url
  end

  def test_should_create_task
    UserSession.create(users(:one))
    assert_difference('Task.count') do
      post :create, :task => { :name => 'Test task' }
    end
  end

  def test_should_redirect_edit_if_logged_out
    get :edit, :id => tasks(:one).id
    assert_redirected_to new_user_session_url
  end

  def test_should_get_edit
    UserSession.create(users(:one))
    get :edit, :id => tasks(:one).id
    assert_response :success
    assert_not_nil assigns(:task)
    assert_not_nil assigns(:tasks)
  end

  def test_should_not_edit_another_users_task
    UserSession.create(users(:one))
    get :edit, :id => tasks(:two).id
    assert_response :missing
  end

  def test_should_redirect_update_if_logged_out
    put :update, :id => tasks(:one).id, :task => { :name => 'Test task'}
    assert_redirected_to new_user_session_url
  end

  def test_should_update_task
    UserSession.create(users(:one))
    put :update, :id => tasks(:one).id, :task => { :name => 'Test task'}
    assert_redirected_to tasks_url
  end

  def test_should_not_update_another_users_task
    UserSession.create(users(:one))
    put :update, :id => tasks(:two).id, :task => { :name => 'Test task'}
    assert_response :missing
  end

  def test_should_redirect_destroy_if_logged_out
    delete :destroy, :id => tasks(:one).id
    assert_redirected_to new_user_session_url
  end

  def test_should_destroy_task
    UserSession.create(users(:one))
    assert_difference('Task.count', -1) do
      delete :destroy, :id => tasks(:one).id
    end
  end
end
