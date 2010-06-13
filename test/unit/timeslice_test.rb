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

  # Should be able to change just the date of a timeslice
  def test_should_change_date
    timeslice = Timeslice.new
    timeslice.user = users(:one)
    timeslice.started = '2009-11-14 13:00:00'
    timeslice.finished = '2009-11-14 14:00:00'
    assert_equal Date.parse('2009-11-14'), timeslice.date
    timeslice.date = Date.parse('2009-12-15')
    assert_equal Date.parse('2009-12-15'), timeslice.date
    assert_equal Time.zone.parse('2009-12-15 13:00:00'), timeslice.started
    assert_equal Time.zone.parse('2009-12-15 14:00:00'), timeslice.finished
    # Should accept a string aswell as a Date object
    timeslice.date = '2009-12-25'
    assert_equal Date.parse('2009-12-25'), timeslice.date
    assert_equal Time.zone.parse('2009-12-25 13:00:00'), timeslice.started
    assert_equal Time.zone.parse('2009-12-25 14:00:00'), timeslice.finished
  end

  # Should get the previous timeslice for the correct user
  def test_should_get_previous
    assert_nil timeslices(:three).previous, 
      "should return nil when there is no previous timeslice"
    assert_equal timeslices(:one), timeslices(:two).previous,
      "returns previous timeslice" 
    assert_nil timeslices(:one).previous,
      "should ignore other users timeslices"
  end

  # Should get the next timeslice for the correct user
  def test_should_get_previous
    assert_nil timeslices(:two).next, 
      "should return nil when there is no next timeslice"
    assert_equal timeslices(:two), timeslices(:one).next,
      "returns next timeslice" 
    assert_nil timeslices(:one).previous,
      "should ignore other users timeslices"
  end

  def test_should_compare_date
    t1 = Timeslice.new
    t1 = Timeslice.new
    t1.user = users(:two)
    t1.started = '2009-11-14 00:00:00'
    t1.finished = '2009-11-14 00:15:00'

    t2 = Timeslice.new
    t2.user = users(:two)
    t2.started = '2009-11-14 23:30:00'
    t2.finished = '2009-11-14 23:45:00'

    assert_equal true, t1.same_day_as?(t2),
      "returns true when comparing timeslices on the same day"

    t2 = Timeslice.new
    t2.user = users(:two)
    t2.started = '2009-11-13 23:30:00'
    t2.finished = '2009-11-13 23:45:00'

    assert_equal false, t1.same_day_as?(t2),
      "returns false when comparing timeslices on different days"

  end

  def test_should_return_total_duration_of_timeslice_array
    assert_equal 7200, Timeslice.total_duration(tasks(:one).timeslices),
      "returns total duration of an array of timeslices"
  end

  def test_should_get_by_date_range
    assert_equal 1, Timeslice.by_date(Date.parse('2009-11-12')).length,
      "should return by date with single date argument"
    assert_equal 5, Timeslice.by_date(Date.parse('2009-11-12'),
                                      Date.parse('2009-11-14')).length,
      "should return by date with date range"
  end

  def test_should_get_by_task_ids
    assert_equal 3, Timeslice.by_task_ids([tasks(:two),tasks(:three)]).count,
      "should return timeslices for list of task ids"
  end

  def test_should_get_started_time_only
    assert_equal '12:00', timeslices(:one).started_time
  end

  def test_should_get_finished_time_only
    assert_equal '13:00', timeslices(:one).finished_time
  end

  def test_should_get_duration_in_minutes
    assert_equal 60, timeslices(:one).minutes
    assert_equal 30, timeslices(:three).minutes
  end

  def test_should_get_hours_and_minutes
    assert_equal '1:00', timeslices(:one).hours_and_minutes
    assert_equal '0:30', timeslices(:three).hours_and_minutes
  end

  def test_should_get_decimal_hours
    assert_equal 1.00, timeslices(:one).decimal_hours
    assert_equal 0.50, timeslices(:three).decimal_hours
  end
end
