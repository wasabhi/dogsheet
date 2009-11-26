require 'test_helper'

class TimeslicesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:timeslices)
    assert_not_nil assigns(:timeslice)
    assert_not_nil assigns(:task)
    assert_not_nil assigns(:date)
    assert_not_nil assigns(:end_date)
  end

  def test_should_get_index_with_todays_date_by_default
    get :index
    assert_not_nil assigns(:date)
    assert_equal Date.today, assigns(:date), "assigns todays date by default"
  end

  def test_should_set_start_and_finished_time_on_empty_timesheet
    get :index, :date => '2009-11-16'
    assert_response :success
    assert_not_nil assigns(:timeslice)
    assert_equal Time.parse('2009-11-16 08:00:00'), assigns(:timeslice).started,
      "sets timeslice started time to 08:00:00 on empty timesheet"
    assert_equal Time.parse('2009-11-16 08:15:00'), assigns(:timeslice).finished,
      "sets timeslice finished time to 08:15:00 on empty timesheet"
  end

  def test_should_assign_timeslices_from_existing_timesheet
    get :index, :date => '2009-11-14'
    assert_response :success
    assert_not_nil assigns(:timeslices)
    assert_equal 2, assigns(:timeslices).count, 
      "Returns two timeslices from existing timesheet"
  end

  def test_should_assign_timeslices_from_timesheet_spanning_multiple_dates
    get :index, :date => '2009-11-12', :end_date => '2009-11-14'
    assert_response :success
    assert_not_nil assigns(:timeslices)
    assert_equal 3, assigns(:timeslices).count, 
      "Returns three timeslices from timesheet spanning multiple days"
  end

  def test_should_set_start_and_finished_time_following_from_last_task_on_populated_timesheet
    get :index, :date => '2009-11-14'
    assert_response :success
    assert_not_nil assigns(:timeslice)
    assert_equal Time.parse('2009-11-14 23:00:00'), assigns(:timeslice).started,
      "sets timeslice started time to 23:00:00 on existing timesheet"
    assert_equal Time.parse('2009-11-14 23:15:00'), assigns(:timeslice).finished,
      "sets timeslice finished time to 23:15:00 on existing timesheet"
  end

  def test_should_get_index_in_xml_format
    get :index, :format => :xml
    assert_not_nil assigns(:timeslices)
  end

  def test_should_get_index_in_csv_format
    get :index, :date => '2009-11-12', :format => 'csv'
    assert_not_nil assigns(:timeslices)
    assert_equal 'text/csv; charset=UTF8; header=present', 
      @response.headers['type'], 'Content type is CSV'
    assert_equal 'attachment;filename=2009-11-12.csv',
      @response.headers['Content-Disposition'], 'Filename is 2009-11-12.csv'
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

    # Create from timeslice/_form partial and also create task
    assert_difference(['Timeslice.count','Task.count']) do
      post :create,  :date => '2009-11-15',
                    :task => {
                      :name => 'Dummy task',
                      :client_id => clients(:one).id
                    },
                    :timeslice => { 
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
