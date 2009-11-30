require 'test_helper'

class TimesliceTest < ActiveSupport::TestCase
  def test_should_save_timeslice
    timeslice = Timeslice.new
    timeslice.started = '2009-11-15 11:00:00'
    timeslice.finished = '2009-11-15 12:00:00'
    timeslice.user = users(:one)
    assert timeslice.save, "Saved valid timeslice"
  end

  def test_should_not_save_without_started
    timeslice = Timeslice.new
    timeslice.finished = '2009-11-15 12:00:00'
    assert !timeslice.save, "Saved timeslice without started"
  end

  def test_should_not_save_without_finished
    timeslice = Timeslice.new
    timeslice.started = '2009-11-15 12:00:00'
    assert !timeslice.save, "Saved timeslice without started"
  end

  def test_should_not_save_without_user
    timeslice = Timeslice.new
    timeslice.started = '2009-11-15 11:00:00'
    timeslice.finished = '2009-11-15 12:00:00'
    assert !timeslice.save, "Saved timeslice without user"
  end

  def test_should_not_save_timeslice_with_finished_before_or_equal_to_started
    timeslice = Timeslice.new
    timeslice.started = '2009-11-15 12:00:00'
    timeslice.finished = '2009-11-15 11:00:00'
    assert !timeslice.save, "Saved timeslice with finished before started"
    timeslice.started = timeslice.finished
    assert !timeslice.save, "Saved timeslice with finished equal to started"
  end

  def test_should_return_timeslice_duration_in_seconds
    timeslice = Timeslice.new
    timeslice.started = '2009-11-15 11:00:00'
    timeslice.finished = '2009-11-15 12:00:00'
    assert_equal 3600, timeslice.duration, "Duration is 3600 seconds"
  end


  # We're testing failure of the following scenarios, in all cases
  # 'new timeslice' save should fail.
  #
  #   |--- old timeslice ---|
  #                     |--- new timeslice ---|
  #
  #                     |--- old timeslice ---|
  #   |--- new timeslice ---|
  #
  #                     |--- old timeslice ---|
  #                  |------ new timeslice ------|
  #
  def test_should_not_save_timeslice_that_overlaps_with_another
    timeslice = Timeslice.new
    timeslice.user = users(:one)
    timeslice.started = '2009-11-14 12:30:00'
    timeslice.finished = '2009-11-14 13:30:00'
    assert !timeslice.save, "Saved timeslice which overlaps end of another"

    timeslice.started = '2009-11-14 11:30:00'
    timeslice.finished = '2009-11-14 12:30:00'
    assert !timeslice.save, "Saved timeslice which overlaps start of another"

    timeslice.started = '2009-11-14 11:00:00'
    timeslice.finished = '2009-11-14 14:00:00'
    assert !timeslice.save, "Saved timeslice which encompasses another"

    fixture = timeslices(:one)
    fixture.started = '2009-11-14 12:30:00'
    fixture.finished = '2009-11-14 13:30:00'
    assert fixture.save, "Updated timeslice with new time overlapping old finished time"
  end

  def test_should_save_timeslice_that_overlaps_with_another_for_different_user
    timeslice = Timeslice.new
    timeslice.user = users(:two)
    timeslice.started = '2009-11-14 12:30:00'
    timeslice.finished = '2009-11-14 13:30:00'
    assert timeslice.save, "Saved timeslice which overlaps end of another users"

    timeslice.started = '2009-11-14 11:30:00'
    timeslice.finished = '2009-11-14 12:30:00'
    assert timeslice.save, "Saved timeslice which overlaps start of another users"

    timeslice.started = '2009-11-14 11:00:00'
    timeslice.finished = '2009-11-14 14:00:00'
    assert timeslice.save, "Saved timeslice which encompasses another users"
  end

  def test_should_save_contiguous_with_another
    timeslice = Timeslice.new
    timeslice.user = users(:one)
    timeslice.started = '2009-11-14 13:00:00'
    timeslice.finished = '2009-11-14 14:00:00'
    assert timeslice.save, "Saved with start time same as existing timeslice finish time"
    timeslice.started = '2009-11-14 11:00:00'
    timeslice.finished = '2009-11-14 12:00:00'
    assert timeslice.save, "Saved with finished time same as existing timeslice start time"
  end
end
