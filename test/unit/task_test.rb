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

  # Should return the total duration of this task and all it's children
  def test_should_return_branch_duration_in_seconds
    assert_equal(7200, tasks(:two).branch_duration)
  end

  def test_should_return_branch_duration_for_date_range
    date_range = Date.parse('2009-11-01') .. Date.parse('2009-11-14')
    array = tasks(:two).branch_duration_array(date_range)
    assert_instance_of(Array, array)
    assert_equal(14, array.length)
  end

  def test_should_get_duration_for_date
    assert_equal(7200,tasks(:one).duration(Date.parse('2009-11-14')))
  end

  def test_should_get_branch_duration_for_date
    assert_equal(5400,tasks(:two).branch_duration(Date.parse('2009-11-14')))
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

  def test_should_return_filename_safe
    task = Task.new(:name => ' T@sk with / !n_valid \ ch*r$ ')
    assert_equal('Tsk_with_n_valid_chr', task.safe_name)
  end

  def test_should_delete_dependent_timeslices
    assert_difference('Timeslice.count', -2) do
      tasks(:one).destroy
    end
  end

  def test_should_return_sparkline
    date_range = Date.parse('2009-11-11') .. Date.parse('2009-11-14')
    assert_equal('0,0,0,7200.0', tasks(:one).sparkline(date_range))
  end
end
