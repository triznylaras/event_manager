require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
def legislators_by_zipcode(zip)
  civic_info.representative_info_by_address(
    address: zip, levels: 'country',
    roles: %w[legislatorUpperBody legislatorLowerBody]
  ).officials
rescue StandardError
  'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') { |file| file.puts form_letter }
end

def clean_homephone(homephone)
  homephone.gsub!(/[^\d]/, '')
  return homephone if homephone.length == 10
  return homephone[1..10] if homephone.length == 11 && homephone[0] == 1

  'Bad number'
end

def count_freq(array)
  array.max_by { |a| array.count(a) }
end

cal = {
  0 => 'sunday',
  1 => 'monday',
  2 => 'tuesday',
  3 => 'wednesday',
  4 => 'thursday',
  5 => 'friday',
  6 => 'saturday'
}

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)
content_size = CSV.read('event_attendees.csv').length

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

content_size -= 1
hour_of_day = Array.new(content_size)
day_of_week = Array.new(content_size)

count = 0
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  homephone = clean_homephone(row[:homephone])
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  reg_date = row[:regdate]
  parse_regdate = DateTime.strptime(reg_date, '%m/%d/%y %H:%M')
  hour_of_day[count] = parse_regdate.hour
  day_of_week[count] = parse_regdate.wday
  count += 1

  form_letter = erb_template.result(binding)
  save_thank_you_letter(id, form_letter)
end

puts "Most active hour is : #{count_freq(hour_of_day)}"
puts "Most active day is : #{cal[count_freq(day_of_week)]}"
