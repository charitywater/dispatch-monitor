require 'spec_helper'

describe Partner do
  let(:partner) { Partner.new }

  describe 'validations' do
    specify do
      expect(partner).to validate_presence_of(:name)
    end

    specify do
      expect(partner).to validate_uniqueness_of(:name)
    end

    it 'does not allow the old name of this Ethiopia partner' do
      expect(partner).to allow_value('Relief Society of Tigray').for(:name)
      expect(partner).not_to allow_value('A Glimmer of Hope').for(:name)
    end
  end

  describe 'associations' do
    specify do
      expect(partner).to have_many(:programs)
    end

    specify do
      expect(partner).to have_many(:projects).through(:programs)
    end
  end
end
