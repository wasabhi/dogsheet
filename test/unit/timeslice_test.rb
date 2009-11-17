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
    valid = Timeslice.new
    valid.started = '2009-11-14 11:00:00'
    valid.finished = '2009-11-14 12:00:00'
    assert valid.save, "Saved valid timeslice for overlap test"

    timeslice = Timeslice.new
    timeslice.started = '2009-11-14 11:30:00'
    timeslice.finished = '2009-11-14 12:30:00'
    assert !timeslice.save, "Saved timeslice which overlaps end of another"

    timeslice = Timeslice.new
    timeslice.started = '2009-11-14 10:30:00'
    timeslice.finished = '2009-11-14 11:30:00'
    assert !timeslice.save, "Saved timeslice which overlaps start of another"

    timeslice = Timeslice.new
    timeslice.started = '2009-11-14 10:00:00'
    timeslice.finished = '2009-11-14 13:00:00'
    assert !timeslice.save, "Saved timeslice which encompasses another"

    valid.started = '2009-11-14 11:30:00'
    valid.finished = '2009-11-14 12:30:00'
    assert valid.save, "Updated timeslice with new time overlapping old finished time"
  end

  def test_should_return_duration_in_hours_and_minutes
    timeslice = Timeslice.new
    timeslice.started = '2009-11-14 11:00:00'
    timeslice.finished = '2009-11-14 12:45:00'
    assert_equal '1:45', timeslice.hours_and_minutes, "Duration in hours and minutes"
    timeslice.finished = '2009-11-15 12:45:00'
    assert_equal '25:45', timeslice.hours_and_minutes, "Duration in hours over and minutes 24 hours"
    timeslice.finished = '2009-11-14 12:00:00'
    assert_equal '1:00', timeslice.hours_and_minutes, "Duration with 0 minutes shows two zeros"
  end

  def test_should_return_duration_in_decimal_hours
    timeslice = Timeslice.new(
        'started' => '2009-11-14 11:00:00',
        'finished' => '2009-11-14 12:00:00'
    )
    assert_equal 1.0, timeslice.decimal_hours, "Duration in decimal hours"
    timeslice.finished = '2009-11-14 11:45:00'
    assert_equal 0.75, timeslice.decimal_hours, "Duration in decimal hours with non-integer return"
    timeslice.finished = '2009-11-15 12:45:00'
    assert_equal 25.75, timeslice.decimal_hours, "Duration in decimal hours over and minutes 24 hours"
  end

  def test_should_format_times_in_short_format
    timeslice = Timeslice.new(
        'started' => '2009-11-14 11:15:00',
        'finished' => '2009-11-14 13:45:00'
    )
    assert_equal '11:15', timeslice.started.to_s(:time_only), "Start time returned in short format"
    assert_equal '13:45', timeslice.finished.to_s(:time_only), "Finsihed time returned in short format"
  end
end
