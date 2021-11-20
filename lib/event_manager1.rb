require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_homephone(homephone)
  homephone.gsub!(/[^\d]/, '')
  if homephone.length == 10
    homephone
  elsif homephone.length == 11 && homephone[0] == 1
    homephone[1..10]
  else
    'Bad number'
  end
end

def time_targeting(array)
  array.max_by { |a| array.count(a) }
end

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

count = 0
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  homephone = clean_homephone(row[:homephone])
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  reg_date = row[:regdate]
  parse_regdate = DateTime.strptime(reg_date,"%m/%d/%y %H:%M")
  hour_of_day[count] = parse_regdate.hour
  count += 1

  form_letter = erb_template.result(binding)
  save_thank_you_letter(id, form_letter)
end

# puts "#{id} #{name}"
puts "Most active hour is : #{time_targeting(hour_of_day)}"
