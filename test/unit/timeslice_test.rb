require 'test_helper'

class TimesliceTest < ActiveSupport::TestCase
  test "should save timeslice" do
    timeslice = Timeslice.new
    timeslice.started = '2009-11-15 11:00:00'
    timeslice.finished = '2009-11-15 12:00:00'
    timeslice.user = users(:one)
    assert timeslice.save, "Saved valid timeslice"
  end

  test "should not save without started" do
    timeslice = Timeslice.new
    timeslice.finished = '2009-11-15 12:00:00'
    assert !timeslice.save, "Saved timeslice without started"
  end

  test "should not save without finished" do
    timeslice = Timeslice.new
    timeslice.started = '2009-11-15 12:00:00'
    assert !timeslice.save, "Saved timeslice without started"
  end

  test "should not save without user" do
    timeslice = Timeslice.new
    timeslice.started = '2009-11-15 11:00:00'
    timeslice.finished = '2009-11-15 12:00:00'
    assert !timeslice.save, "Saved timeslice without user"
  end

  test "should not save timeslice with finished before or equal to started" do
    timeslice = Timeslice.new
    timeslice.started = '2009-11-15 12:00:00'
    timeslice.finished = '2009-11-15 11:00:00'
    assert !timeslice.save, "Saved timeslice with finished before started"
    timeslice.started = timeslice.finished
    assert !timeslice.save, "Saved timeslice with finished equal to started"
  end

  test "should return timeslice duration in seconds" do
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
  test "should not save timeslice that overlaps with another" do
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

  test "should save timeslice that overlaps with another for different user" do
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

  test "should save contiguous with another" do
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
  test "should change date" do
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
  test "should get previous" do
    assert_nil timeslices(:three).previous, 
      "should return nil when there is no previous timeslice"
    assert_equal timeslices(:one), timeslices(:two).previous,
      "returns previous timeslice" 
    assert_nil timeslices(:one).previous,
      "should ignore other users timeslices"
  end

  # Should get the next timeslice for the correct user
  test "should get next" do
    assert_nil timeslices(:two).next, 
      "should return nil when there is no next timeslice"
    assert_equal timeslices(:two), timeslices(:one).next,
      "returns next timeslice" 
    assert_nil timeslices(:one).previous,
      "should ignore other users timeslices"
  end

  test "should compare date" do
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

  test "should return total duration of timeslice array" do
    assert_equal 7200, Timeslice.total_duration(tasks(:one).timeslices),
      "returns total duration of an array of timeslices"
  end

  test "should get by date range" do
    assert_equal 1, Timeslice.by_date(Date.parse('2009-11-12')).length,
      "should return by date with single date argument"
    assert_equal 5, Timeslice.by_date(Date.parse('2009-11-12'),
                                      Date.parse('2009-11-14')).length,
      "should return by date with date range"
  end

  test "should get by task ids" do
    assert_equal 3, Timeslice.by_task_ids([tasks(:two),tasks(:three)]).count,
      "should return timeslices for list of task ids"
  end

  test "should get started time only" do
    assert_equal '12:00', timeslices(:one).started_time
  end

  test "should get finished time only" do
    assert_equal '13:00', timeslices(:one).finished_time
  end

  test "should get duration in minutes" do
    assert_equal 60, timeslices(:one).minutes
    assert_equal 30, timeslices(:three).minutes
  end

  test "should get hours and minutes" do
    assert_equal '1:00', timeslices(:one).hours_and_minutes
    assert_equal '0:30', timeslices(:three).hours_and_minutes
  end

  test "should get decimal hours" do
    assert_equal 1.00, timeslices(:one).decimal_hours
    assert_equal 0.50, timeslices(:three).decimal_hours
  end

  test "should get unbilled timeslices" do
    assert_instance_of Array, Timeslice.unbilled
    assert_equal 5, Timeslice.unbilled.length

    assert_difference 'Timeslice.unbilled.length', -1 do
      assert timeslices(:one).update_attribute(:invoice_number, '12345')
    end
  end

  test "should get unbilled timeslices for a task branch" do
    # Returns timeslices explicitly for the task by default
    assert_equal 2, Timeslice.unbilled.by_task(tasks(:two)).length

    # Returns timeslices for the task and all it's children if passed
    # deep argument
    assert_equal 3, Timeslice.unbilled.by_task(tasks(:two), true).length
  end
end
