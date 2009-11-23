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

  def test_should_return_duration_in_hours_and_minutes
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
    assert_equal '1:15', task.hours_and_minutes, "Duration in hours and minutes"
  end

  def test_should_return_duration_in_hours_and_minutes
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
    assert_equal 1.25, task.decimal_hours, "Duration in decimal hours"
  end

  def test_should_return_name_with_client_shortcode
    task = Task.new
    task.name = "Test task"
    task.client = clients(:one)
    assert_equal "MYST: Test task", task.name_with_prefix, "Name with client shortcode prefix"
  end
end
