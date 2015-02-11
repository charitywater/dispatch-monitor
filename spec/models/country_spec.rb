require 'spec_helper'

describe Country do
  let(:country) { Country.new }

  describe 'validations' do
    specify do
      expect(country).to validate_uniqueness_of(:name)
    end

    specify do
      expect(country).to validate_presence_of(:name)
    end
  end

  describe 'associatons' do
    specify do
      expect(country).to have_many(:programs)
    end

    specify do
      expect(country).to have_many(:projects).through(:programs)
    end
  end
end
