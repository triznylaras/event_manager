require 'spec_helper'

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
end
