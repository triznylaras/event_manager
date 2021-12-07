require 'spec_helper'
require 'pry-byebug'

describe Main do
  let(:main) { Main.new }

  describe '#initialize' do
    it 'raises an exception when initialized with {}' do
      expect { Main.new({}) }.to raise_error
    end
  end

  describe '#clean_zipcode' do
    it 'return 5 zeros if the zipcode is empty' do
      expect(main.send(:clean_zipcode, '')).to eq('00000')
    end

    it 'return the zipcode if its length is exactly 5 digits' do
      zipcode = 200_10
      expect(main.send(:clean_zipcode, zipcode)).to eq(zipcode.to_s)
    end

    it 'truncate to first 5 digits if the length is more than 5 digits' do
      zipcode = 981_221
      expect(main.send(:clean_zipcode, zipcode)).to eq(zipcode.to_s[0..4])
    end
  end

  describe '#legislators_by_zipcode' do
    it 'return text if zipcode is empty' do
      expect(main.send(:legislators_by_zipcode, '')).to eq('You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials')
    end
  end

  describe '#clean_homephone' do
    it "return 'Bad number' if number's length is less than 10 digits or more than 11 digits" do
      homephone = 9.82E+00
      expect(main.send(:clean_homephone, homephone.to_s)).to eq('Bad number')
    end

    it 'return homephone if phone number is exactly 10 digits' do
      homephone = 808_497_400_0
      expect(main.send(:clean_homephone, homephone.to_s)).to eq(homephone.to_s)
    end

    it 'trim the first digit and use remaining 10 digits if phone number is 11 digits and first number is 1' do
      homephone = 140_186_850_00
      expect(main.send(:clean_homephone, homephone.to_s)).to eq(homephone.to_s[1..10])
    end

    it "return 'Bad number' if number is 11 digits and the first number is not 1" do
      homephone = 280_849_740_00
      expect(main.send(:clean_homephone, homephone.to_s)).to eq('Bad number')
    end

    it "return 'Bad number' if number is more than 11 digits" do
      homephone = 414-520-50001
      expect(main.send(:clean_homephone, homephone.to_s)).to eq('Bad number')
    end
  end

  describe '#parse_date' do
    it "return formatted date" do
      date = DateTime.new(2009, 2, 2, 11, 29)
      # binding.pry
      expect(main.send(:parse_date).with(date)).to eq()
    end
  end
end
