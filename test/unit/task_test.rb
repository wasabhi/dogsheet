require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  def test_should_not_save_task_without_name
    task = Task.new
    assert !task.save, "Saved task without name"
  end

  def test_should_save_task
    task = Task.new
    task.name = "Test task"
    assert task.save, "Saved a valid task"
  end

  def test_should_return_duration_in_seconds
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

  def test_should_return_depth_prefix_string
    assert_equal 'Top level task for user one', tasks(:one).name_with_depth,
      'top level task has no prefix'
    assert_equal '-Second level task for user two', tasks(:three).name_with_depth,
      'second level task has single dash prefix'
    assert_equal '>Second level task for user two', tasks(:three).name_with_depth('>'),
      'second level task has custom prefix'
  end

  def test_should_return_name_with_ancestors
    assert_equal 'Top level task for user one', tasks(:one).name_with_ancestors,
      'top level task has no ancestors'
    assert_equal 'Top level task for user two:Second level task for user two', 
      tasks(:three).name_with_ancestors, 'second level task has one ancestor'
    assert_equal 'Top level task for user two > Second level task for user two', 
      tasks(:three).name_with_ancestors(' > '), 
      'second level task has custom join string'
  end

  def test_should_delete_dependent_timeslices
    assert_difference('Timeslice.count', -3) do
      tasks(:one).destroy
    end
  end
end
