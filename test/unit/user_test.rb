require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def test_should_return_timeslices_by_day
    start_date = Date.parse('2009-11-12')
    end_date = Date.parse('2009-11-14')
    assert_equal 1, users(:one).timeslices_by_date(start_date).count,
      "return timeslices for a single day"
    assert_equal 3, users(:one).timeslices_by_date(start_date,end_date).count,
      "return timeslices for a date range"
  end
end
