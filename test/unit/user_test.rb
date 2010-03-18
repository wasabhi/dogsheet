require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def test_should_not_save_invalid_time_step
    # Cannot be nil
    users(:one).time_step = nil
    assert !users(:one).save

    users(:one).time_step = 3
    assert !users(:one).save

    # These are all valid
    User::TIME_STEPS.each do |minutes|
      users(:one).time_step = minutes
      assert users(:one).save, "should save with time step of #{minutes}"
    end
  end

  def test_should_set_default_time_step
    user = User.new
    assert_equal 15, user.time_step, "time step defaults to 15"
  end

  def test_should_set_default_time_zone
    user = User.new
    assert_equal 'Auckland', user.time_zone, "time zone defaults to Auckland"
  end
end
