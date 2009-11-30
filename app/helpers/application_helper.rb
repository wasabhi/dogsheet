# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Returns duration in seconds formatted as 00:00
  def hours_and_minutes(seconds)
    minutes = seconds / 60
    "%d:%02d" % [minutes / 60, minutes % 60]
  end

  # Returns a duration in seconds formatted as decimal hours
  def decimal_hours(seconds)
    seconds / 60 / 60
  end
end
