require "test_helper"

class Office365UrlTest < Minitest::Test
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

    @url_with_defaults_required = "https://outlook.office.com/calendar/0/deeplink/compose?path=/calendar/action/compose&rru=addevent" +
                                  "&subject=Holly%27s%208th%20Birthday%21" + 
                                  "&startdt=#{@next_month_year}-#{@next_month_month}-#{@next_month_day}T12:30:00Z" + 
                                  "&enddt=#{@next_month_year}-#{@next_month_month}-#{@next_month_day}T13:30:00Z"

  end

  def test_with_only_required_attributes
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,@hour,@minute,@second), 
      title: @title, 
      timezone: @timezone
    )
    assert cal.office365_url == @url_with_defaults_required
  end

  def test_without_end_datetime
    # should set duration as 1 hour
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone)
    assert cal.office365_url == "https://outlook.office.com/calendar/0/deeplink/compose?path=/calendar/action/compose&rru=addevent" +
                                 "&subject=Holly%27s%208th%20Birthday%21" + 
                                 "&startdt=#{@next_month_year}-#{@next_month_month}-#{@next_month_day}T12:30:00Z" + 
                                 "&enddt=#{@next_month_year}-#{@next_month_month}-#{@next_month_day}T13:30:00Z"
  end

  def test_with_end_datetime
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,17,00,00,0), 
      title: @title, 
      timezone: @timezone
    )
    assert cal.office365_url == "https://outlook.office.com/calendar/0/deeplink/compose?path=/calendar/action/compose&rru=addevent" +
                                 "&subject=Holly%27s%208th%20Birthday%21" + 
                                 "&startdt=#{@next_month_year}-#{@next_month_month}-#{@next_month_day}T12:30:00Z" + 
                                 "&enddt=#{@next_month_year}-#{@next_month_month}-#{@next_month_day}T16:00:00Z"
  end

  def test_with_end_datetime_crossing_over_midnight
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day.to_i+1,17,00,00,0), 
      title: @title, 
      timezone: @timezone
    )
    assert cal.office365_url == "https://outlook.office.com/calendar/0/deeplink/compose?path=/calendar/action/compose&rru=addevent" +
                                 "&subject=Holly%27s%208th%20Birthday%21" + 
                                 "&startdt=#{@next_month_year}-#{@next_month_month}-#{@next_month_day}T12:30:00Z" + 
                                 "&enddt=#{@next_month_year}-#{@next_month_month}-#{@next_month_day.to_i+1}T16:00:00Z"
  end

  def test_with_location
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, location: @location)
    assert cal.office365_url == @url_with_defaults_required + "&location=Flat%204%2C%20The%20Edge%2C%2038%20Smith-Dorrien%20St%2C%20London%2C%20N1%207GU"
  end

  def test_with_url_without_description
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, url: @url)
    assert cal.office365_url == @url_with_defaults_required + "&body=https%3A%2F%2Fwww.example.com%2Fevent-details"
  end

  def test_with_url_and_description
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, url: @url, description: @description)
    assert cal.office365_url == @url_with_defaults_required + "&body=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21%3Cbr%3E%3Cbr%3Ehttps%3A%2F%2Fwww.example.com%2Fevent-details"
  end

  def test_convert_newline_to_url_encoded_br
    # for other providers you pass newline `\n` to get a multi-line body
    # but this does not work for Office36/Outlook.com
    # Instead we must use `<br>` (url encoded: `%3Cbr%3E`)
    cal = AddToCalendar::URLs.new(start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), title: @title, timezone: @timezone, description: "multi\nline\ndescription")
    assert cal.office365_url == @url_with_defaults_required + "&body=multi%3Cbr%3Eline%3Cbr%3Edescription"
  end

  def test_description_with_newlines_from_user_input
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      title: @title, 
      timezone: @timezone, 
      url: @url, 
      description: "Come join us for lots of fun & cake!\n\nDon't forget your swimwear!"
    )
    assert cal.office365_url == @url_with_defaults_required + "&body=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21%3Cbr%3E%3Cbr%3EDon%27t%20forget%20your%20swimwear%21%3Cbr%3E%3Cbr%3Ehttps%3A%2F%2Fwww.example.com%2Fevent-details"
  end

  def test_add_url_to_description_false_without_url
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      title: @title, 
      timezone: @timezone,
      add_url_to_description: false,
    )
    assert cal.office365_url == @url_with_defaults_required
  end

  def test_add_url_to_description_false_with_url
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      title: @title, 
      timezone: @timezone,
      add_url_to_description: false,
      url: @url,
    )
    assert cal.office365_url == @url_with_defaults_required
  end

  def test_with_all_attributes
    cal = AddToCalendar::URLs.new(
      start_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,13,30,00,0), 
      end_datetime: Time.new(@next_month_year,@next_month_month,@next_month_day,17,00,00,0), 
      title: @title, 
      timezone: @timezone,
      url: @url,
      location: @location,
      description: @description,
    )
    assert cal.office365_url == "https://outlook.office.com/calendar/0/deeplink/compose?path=/calendar/action/compose&rru=addevent" + 
                                 "&subject=Holly%27s%208th%20Birthday%21" + 
                                 "&startdt=#{@next_month_year}-#{@next_month_month}-#{@next_month_day}T12:30:00Z" + 
                                 "&enddt=#{@next_month_year}-#{@next_month_month}-#{@next_month_day}T16:00:00Z" + 
                                 "&body=Come%20join%20us%20for%20lots%20of%20fun%20%26%20cake%21%3Cbr%3E%3Cbr%3Ehttps%3A%2F%2Fwww.example.com%2Fevent-details" + 
                                 "&location=Flat%204%2C%20The%20Edge%2C%2038%20Smith-Dorrien%20St%2C%20London%2C%20N1%207GU"
  end
  
end