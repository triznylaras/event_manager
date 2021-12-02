require 'spec_helper'

describe Main do
  let(:main) { Main.new }

  context '#initialize' do
    it 'raises an exception when initialized with {}' do
      expect { Main.new({}) }.to raise_error
    end
  end
end
