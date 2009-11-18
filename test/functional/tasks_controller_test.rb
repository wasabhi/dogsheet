require 'test_helper'

class TasksControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index, :client_id => clients(:one).id
    assert_response :success
    assert_not_nil assigns(:tasks)
    assert_equal 2, assigns(:tasks).count
  end

  def test_should_get_new
    get :new, :client_id => clients(:one).id
    assert_response :success
  end

  def test_should_create_task
    assert_difference('Task.count') do
      post :create, :client_id => clients(:one).id, :task => { :name => 'Test task' }
    end
  end

  def test_should_get_edit
    get :edit, :id => tasks(:one).id
    assert_response :success
  end

  def test_should_update_task
    put :update, :id => tasks(:one).id, :task => { :name => 'Test task'}
  end

  def test_should_destroy_task
    assert_difference('Task.count', -1) do
      delete :destroy, :id => tasks(:one).id
    end
  end
end
