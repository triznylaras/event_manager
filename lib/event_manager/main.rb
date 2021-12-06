require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

class Main
  def initialize
    @contents = CSV.open(
      'event_attendees.csv',
      headers: true,
      header_converters: :symbol
    )
    @content_size = CSV.read('event_attendees.csv').length
    template_letter = File.read('form_letter.erb')
    @erb_template = ERB.new template_letter
    @hour_of_day = Array.new(@content_size)
    @day_of_week = Array.new(@content_size)
    process_content
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
    return phone[1..10] if phone.length == 11 && phone[0] == 1

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
    parse_regdate = DateTime.strptime(date, '%m/%d/%y %H:%M')
    @hour_of_day[@data_count] = parse_regdate.hour
    @day_of_week[@data_count] = parse_regdate.wday
  end

  def content_data(row)
    # name = row[:first_name]
    @homephone = clean_homephone(row[:homephone])
    zipcode = clean_zipcode(row[:zipcode])
    @legislators = legislators_by_zipcode(zipcode)
  end

  puts 'EventManager initialized.'

  def process_content
    @content_size -= 1

    @data_count = 0
    @contents.each do |row|
      id = row[0]
      content_data(row)
      reg_date = parse_date(row[:regdate])
      @data_count += 1

      form_letter = @erb_template.result(binding)
      save_thank_you_letter(id, form_letter)
    end
    print_content_info
  end

  def print_content_info
    puts "Most active hour is : #{count_freq(@hour_of_day)}"
    puts "Most active day is : #{parse_day[count_freq(@day_of_week)]}"
  end
end
