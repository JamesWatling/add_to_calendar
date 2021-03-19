require "test_helper"

class YahooUrlTest < Minitest::Test
  def setup
    # next_month = Time.now + 60*60*24*30
    @next_month_year = "2020"
    @next_month_month = "05"
    @next_month_day = "12"
    @hour = 13
    @minute = 30
    @second = 00

    @title = "Holly's 8th Birthday!"
    @timezone = "Europe/London"
    @url = "https://www.example.com/event-details"
    @location = "Flat 4, The Edge, 38 Smith-Dorrien St, London, N1 7GU"
    @description = "Come join us for lots of fun & cake!"

    @url_with_defaults_required = "https://calendar.yahoo.com/?v=60&view=d&type=20" +
                                  "&title=Holly%27s%208th%20Birthday%21" + 
                                  "&st=#{@next_month_year}#{@next_month_month}#{@next_month_day}T123000Z" + 
                                  "&dur=0100"

  end

  def test_with_only_required_attributes
    cal = AddToCalendarLinks::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,@hour,@minute,@second), 
      title: @title, 
      timezone: @timezone
    )
    assert cal.yahoo_url == @url_with_defaults_required
  end

  def test_without_end_datetime
    # should set duration as 1 hour
    cal = AddToCalendarLinks::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone)
    assert cal.yahoo_url == "https://calendar.yahoo.com/?v=60&view=d&type=20" +
                            "&title=Holly%27s%208th%20Birthday%21" + 
                            "&st=#{@next_month_year}#{@next_month_month}#{@next_month_day}T123000Z" + 
                            "&dur=0100"
  end

  def test_with_end_datetime
    cal = AddToCalendarLinks::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,17,00,00,0), 
      title: @title, 
      timezone: @timezone
    )
    assert cal.yahoo_url == "https://calendar.yahoo.com/?v=60&view=d&type=20" +
                            "&title=Holly%27s%208th%20Birthday%21" + 
                            "&st=#{@next_month_year}#{@next_month_month}#{@next_month_day}T123000Z" + 
                            "&dur=0330"
  end

  def test_with_end_datetime_crossing_over_midnight
    cal = AddToCalendarLinks::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day.to_i+1,17,00,00,0), 
      title: @title, 
      timezone: @timezone
    )
    assert cal.yahoo_url == "https://calendar.yahoo.com/?v=60&view=d&type=20" +
                            "&title=Holly%27s%208th%20Birthday%21" + 
                            "&st=#{@next_month_year}#{@next_month_month}#{@next_month_day}T123000Z" + 
                            "&dur=2730"
  end

  def test_with_location
    cal = AddToCalendarLinks::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, location: @location)
    assert cal.yahoo_url == @url_with_defaults_required + "&in_loc=Flat%204%2C%20The%20Edge%2C%2038%20Smith-Dorrien%20St%2C%20London%2C%20N1%207GU"
  end

  def test_with_url_without_description
    cal = AddToCalendarLinks::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, url: @url)
    assert cal.yahoo_url == @url_with_defaults_required + "&desc=https%3A%2F%2Fwww.example.com%2Fevent-details"
  end

  def test_with_url_and_description
    cal = AddToCalendarLinks::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, url: @url, description: @description)
    assert cal.yahoo_url == @url_with_defaults_required + "&desc=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21%0A%0Ahttps%3A%2F%2Fwww.example.com%2Fevent-details"
  end

  def test_description_with_newlines_from_user_input
    cal = AddToCalendarLinks::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      title: @title, 
      timezone: @timezone, 
      url: @url, 
      description: "Come join us for lots of fun & cake!\n\nDon't forget your swimwear!"
    )
    assert cal.yahoo_url == @url_with_defaults_required + "&desc=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21%0A%0ADon%27t%20forget%20your%20swimwear%21%0A%0Ahttps%3A%2F%2Fwww.example.com%2Fevent-details"
  end

  def test_add_url_to_description_false_without_url
    cal = AddToCalendarLinks::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      title: @title, 
      timezone: @timezone,
      add_url_to_description: false,
    )
    assert cal.yahoo_url == @url_with_defaults_required
  end

  def test_add_url_to_description_false_with_url
    cal = AddToCalendarLinks::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      title: @title, 
      timezone: @timezone,
      add_url_to_description: false,
      url: @url,
    )
    assert cal.yahoo_url == @url_with_defaults_required
  end

  def test_with_all_attributes
    cal = AddToCalendarLinks::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,17,00,00,0), 
      title: @title, 
      timezone: @timezone,
      url: @url,
      location: @location,
      description: @description,
    )
    assert cal.yahoo_url == "https://calendar.yahoo.com/?v=60&view=d&type=20" +
                            "&title=Holly%27s%208th%20Birthday%21" + 
                            "&st=#{@next_month_year}#{@next_month_month}#{@next_month_day}T123000Z" + 
                            "&dur=0330" +
                            "&desc=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21%0A%0Ahttps%3A%2F%2Fwww.example.com%2Fevent-details" + 
                            "&in_loc=Flat%204%2C%20The%20Edge%2C%2038%20Smith-Dorrien%20St%2C%20London%2C%20N1%207GU"
  end
  
end
