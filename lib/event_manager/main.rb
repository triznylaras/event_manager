require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'pry-byebug'

class Main
  def initialize
    @content_size = CSV.read('event_attendees.csv').length
    template_letter = File.read('form_letter.erb')
    @erb_template = ERB.new template_letter
    @hour_of_day = Array.new(@content_size)
    @day_of_week = Array.new(@content_size)
  end

  def process
    @content_size -= 1

    data_count = 0
    contents.each do |row|
      id = row[0]
      name = row[:first_name]
      @homephone = clean_homephone(row[:homephone])
      @zipcode = clean_zipcode(row[:zipcode])
      legislators = legislators_by_zipcode(@zipcode)
      data_count += 1
      reg_date = parse_date(row[:regdate])
      hour_list(reg_date, data_count)
      day_list(reg_date, data_count)
      form_letter = @erb_template.result(binding)
      save_thank_you_letter(id, form_letter)
    end
    result
  end

  def result
    puts "Most active hour is : #{count_freq(@hour_of_day)}"
    puts "Most active day is : #{parse_day[count_freq(@day_of_week)]}"
  end

  private

  def contents
    CSV.open(
      'event_attendees.csv',
      headers: true,
      header_converters: :symbol
    )
  end

  def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, '0')[0..4]
  end

  def legislators_by_zipcode(zip)
    civic_info_service.representative_info_by_address(
      address: zip, levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end

  def civic_info_service
    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
    civic_info
  end

  def save_thank_you_letter(id, form_letter)
    Dir.mkdir('output') unless Dir.exist?('output')

    filename = "output/thanks_#{id}.html"

    File.open(filename, 'w') { |file| file.puts form_letter }
  end

  def clean_homephone(phone)
    phone.gsub!(/[^\d]/, '')
    return phone if phone.length == 10
    return phone[1..10] if phone.length == 11 && phone[0] == '1'

    'Bad number'
  end

  def count_freq(array)
    array.max_by { |a| array.count(a) }
  end

  def parse_day
    {
      0 => 'sunday',
      1 => 'monday',
      2 => 'tuesday',
      3 => 'wednesday',
      4 => 'thursday',
      5 => 'friday',
      6 => 'saturday'
    }
  end

  def parse_date(date)
    DateTime.strptime(date, '%m/%d/%y %H:%M')
  end

  def hour_list(date, data_count)
    @hour_of_day[data_count] = date.hour
  end

  def day_list(date, data_count)
    @day_of_week[data_count] = date.wday
  end
end

Main.new.process
