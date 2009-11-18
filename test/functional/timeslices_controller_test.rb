require 'test_helper'

class TimeslicesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:timeslices)
    get :index, :format => :xml
    assert_not_nil assigns(:timeslices)
  end

  def test_should_get_new
    get :new, :task_id => tasks(:one).id
    assert_response :success
  end

  def test_should_create_timeslice
    assert_difference('Timeslice.count') do
      post :create, :task_id => tasks(:one).id,
                    :timeslice => { 
                      :started => '2009-11-14 14:00:00',
                      :finished => '2009-11-14 15:00:00'
                    }
    end
    assert_difference('Timeslice.count') do
      post :create, :task_id => tasks(:one).id,
                    :timeslice => { 
                      :started_time => '15:00',
                      :finished_time => '16:00'
                    }
    end
  end

  def test_should_get_edit
    get :edit, :id => timeslices(:one).id
    assert_response :success
  end

  def test_should_update_timeslice
    put :update,  :id => timeslices(:one).id,
                  :timeslice => {
                      :started => '2009-11-14 14:00:00',
                      :finished => '2009-11-14 15:00:00'
                  }
  end

  def test_should_destroy_timeslice
    assert_difference('Timeslice.count', -1) do
      delete :destroy, :id => timeslices(:one).id
    end
  end
end
