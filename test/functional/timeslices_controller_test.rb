require 'test_helper'

class TimeslicesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:timeslices)
    assert_not_nil assigns(:timeslice)
    assert_not_nil assigns(:task)

    get :index, :format => :xml
    assert_not_nil assigns(:timeslices)

    get :index, :date => '2009-11-16'
    assert_response :success
    assert_not_nil assigns(:timeslices)
    assert_not_nil assigns(:timeslice)
    assert_not_nil assigns(:task)
    assert_equal Time.parse('2009-11-16 08:00:00'), assigns(:timeslice).started,
      "sets timeslice started time to 08:00:00"
    assert_equal Time.parse('2009-11-16 08:15:00'), assigns(:timeslice).finished,
      "sets timeslice started time to 08:15:00"
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
    assert_redirected_to timesheet_path('2009-11-14')

    # Create with date and times as separate params
    assert_difference('Timeslice.count') do
      post :create, :task_id => tasks(:one).id, :date => '2009-11-15',
                    :timeslice => { 
                      :started_time => '15:00',
                      :finished_time => '16:00'
                    }
    end

    # Create from timeslice/_form partial
    assert_difference('Timeslice.count') do
      post :create,  :date => '2009-11-15',
                    :timeslice => { 
                      :task_id => tasks(:one).id,
                      :started_time => '15:00',
                      :finished_time => '16:00'
                    }
    end
  end

  def test_should_set_default_timeslice_task
    get :index, :date => '2009-11-15'
    assert_response :success
    assert_not_nil assigns(:timeslice), "assigns a timeslice"
    assert_equal timeslices(:one).task, assigns(:timeslice).task, 
      "assigns a timeslice with the most recently worked task when day sheet is empty"
    
    get :index, :date => '2009-11-12'
    assert_response :success
    assert_not_nil assigns(:timeslice), "assigns a timeslice"
    assert_equal timeslices(:three).task, assigns(:timeslice).task, 
      "assigns a timeslice with the last task worked on for an active day sheet"
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
