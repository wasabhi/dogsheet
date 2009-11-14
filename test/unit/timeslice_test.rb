require 'test_helper'

class TimesliceTest < ActiveSupport::TestCase
  def test_should_save_timeslice
    timeslice = Timeslice.new
    timeslice.started = '2009-11-14 11:00:00'
    timeslice.finished = '2009-11-14 12:00:00'
    assert timeslice.save, "Saved valid timeslice"
  end

  def test_should_not_save_without_started
    timeslice = Timeslice.new
    timeslice.finished = '2009-11-14 12:00:00'
    assert !timeslice.save, "Saved timeslice without started"
  end

  def test_should_not_save_without_finished
    timeslice = Timeslice.new
    timeslice.started = '2009-11-14 12:00:00'
    assert !timeslice.save, "Saved timeslice without started"
  end

  def test_should_not_save_timeslice_with_finished_before_or_equal_to_started
    timeslice = Timeslice.new
    timeslice.started = '2009-11-14 12:00:00'
    timeslice.finished = '2009-11-14 11:00:00'
    assert !timeslice.save, "Saved timeslice with finished before started"
    timeslice.started = timeslice.finished
    assert !timeslice.save, "Saved timeslice with finished equal to started"
  end

  def test_should_return_timeslice_duration_in_seconds
    timeslice = Timeslice.new
    timeslice.started = '2009-11-14 11:00:00'
    timeslice.finished = '2009-11-14 12:00:00'
    assert_equal 3600, timeslice.duration, "Duration is 3600 seconds"
  end

  def test_should_not_save_timeslice_that_overlaps_with_another
    timeslice = Timeslice.new
    timeslice.started = '2009-11-14 11:00:00'
    timeslice.finished = '2009-11-14 12:00:00'
    assert timeslice.save, "Saved valid timeslice for overlap test"

    timeslice = Timeslice.new
    timeslice.started = '2009-11-14 11:30:00'
    timeslice.finished = '2009-11-14 12:30:00'
    assert !timeslice.save, "Saved timeslice which overlaps with another"
  end
end
