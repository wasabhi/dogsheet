require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  test "should not save task without name" do
    task = Task.new
    assert !task.save, "Saved task without name"
  end

  test "should save task" do
    task = Task.new
    task.name = "Test task"
    assert task.save, "Saved a valid task"
  end

  test "should not save a task with a duplicate name" do
    task = Task.new
    task.name = "Top level task for user one"
    task.user = users(:one)
    assert !task.save
  end

  test "should save a duplicate task name if user is different" do
    task = Task.new
    task.name = "Top level task for user one"
    task.user = users(:two)
    assert_difference 'Task.count' do
      assert task.save
    end
  end

  test "should return duration in seconds" do
    task = Task.new
    task.name = "Test task"
    task.save
    timeslice = task.timeslices.build
    timeslice.started = '2009-11-13 12:00:00'
    timeslice.finished = '2009-11-13 13:00:00'
    timeslice.save
    timeslice = task.timeslices.build
    timeslice.started = '2009-11-13 13:00:00'
    timeslice.finished = '2009-11-13 13:15:00'
    timeslice.save
    assert_equal 4500, task.duration, "Returned duration of tasks timeslices in seconds"
  end

  # Should return the total duration of this task and all it's children
  test "should return branch duration in seconds" do
    assert_equal(7200, tasks(:two).branch_duration)
  end

  test "should return branch duration for date range" do
    date_range = Date.parse('2009-11-01') .. Date.parse('2009-11-14')
    array = tasks(:two).branch_duration_array(date_range)
    assert_instance_of(Array, array)
    assert_equal(14, array.length)
  end

  test "should get duration for date" do
    assert_equal(7200,tasks(:one).duration(Date.parse('2009-11-14')))
  end

  test "should get branch duration for date" do
    assert_equal(5400,tasks(:two).branch_duration(Date.parse('2009-11-14')))
  end

  test "should return depth prefix string" do
    assert_equal 'Top level task for user one', tasks(:one).name_with_depth,
      'top level task has no prefix'
    assert_equal '-Second level task for user two', tasks(:three).name_with_depth,
      'second level task has single dash prefix'
    assert_equal '>Second level task for user two', tasks(:three).name_with_depth('>'),
      'second level task has custom prefix'
  end

  test "should return name with ancestors" do
    assert_equal 'Top level task for user one', tasks(:one).name_with_ancestors,
      'top level task has no ancestors'
    assert_equal 'Top level task for user two:Second level task for user two', 
      tasks(:three).name_with_ancestors, 'second level task has one ancestor'
    assert_equal 'Top level task for user two > Second level task for user two', 
      tasks(:three).name_with_ancestors(' > '), 
      'second level task has custom join string'
  end

  test "should return filename safe" do
    task = Task.new(:name => ' T@sk with / !n_valid \ ch*r$ ')
    assert_equal('Tsk_with_n_valid_chr', task.safe_name)
  end

  test "should delete dependent timeslices" do
    assert_difference('Timeslice.count', -2) do
      tasks(:one).destroy
    end
  end

  test "should return sparkline" do
    date_range = Date.parse('2009-11-11') .. Date.parse('2009-11-14')
    assert_equal('0,0,0,7200.0', tasks(:one).sparkline(date_range))
  end

  # If passed a string containing NAME_SEPARATOR, create multiple tasks
  # as children of each other
  test "split and create" do
    assert_difference 'Task.count', 3 do
      tasks = Task.split_and_create('Test 1 : Test 2:Test 3')
      assert_instance_of Array, tasks
      tasks.inject(nil) do |previous,current|
        assert_instance_of Task, current
        assert_equal previous, current.parent unless previous.nil?
        current
      end
    end
  end

  # Task#split_and_create should take an optional root task to be set
  # as the parent of the first created task
  test "split and create with root task" do
    assert_difference 'Task.count', 2 do
      tasks = Task.split_and_create('Test:Test', tasks(:one))
      assert_equal tasks(:one), tasks.first.parent
    end
  end

  # Task name should be unique per branch
  test "name should be unique per branch" do
    assert_difference 'Task.count' do
      assert Task.create(:name => tasks(:two).name, :parent => tasks(:two),
        :user => users(:two)), "can have the same task name on different levels"
    end
    assert_no_difference 'Task.count' do
      assert Task.create(:name => tasks(:three).name, :parent => tasks(:two),
        :user => users(:two)), "cannot have the same task name on the same branch"
    end
  end

  # Task should inherit rate from parent if nil
  test "should inherit rate from parent" do
    assert_nil tasks(:one).rate
    assert_equal 1.23, tasks(:two).rate
    assert_equal 1.23, tasks(:three).rate
  end
end
