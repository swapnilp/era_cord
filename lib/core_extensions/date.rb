class Date
  def self.cwday_day(cwday)
    case cwday
    when 1
      'Monday'
    when 2
      'Tuesday'
    when 3
      "Wednesday"
      
    when 4
      "Thusday"
    when 5
      "Friday"
    when 6
      "Saturday"
    when 7
      "Sunday"
    end

  end

  def database_time #(dd_date)
    self.to_time.in_time_zone('UTC')
  end
end
