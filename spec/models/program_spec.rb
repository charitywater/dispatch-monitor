require 'spec_helper'

describe Program do
  let(:program) { Program.new }

  describe 'validations' do
    specify do
      expect(program).to validate_presence_of(:country_id)
    end

    specify do
      expect(program).to validate_presence_of(:partner_id)
    end

    specify do
      create(:program)

      expect(program).to validate_uniqueness_of(:partner_id).scoped_to(:country_id)
    end
  end

  describe 'associations' do
    specify do
      expect(program).to belong_to(:partner)
    end

    specify do
      expect(program).to belong_to(:country)
    end

    specify do
      expect(program).to have_many(:projects)
    end

    specify do
      expect(program).to have_many(:vehicles)
    end

    specify do
      expect(program).to have_many(:survey_responses).through(:projects)
    end

    specify do
      expect(program).to have_many(:tickets).through(:survey_responses)
    end
  end

  describe 'scopes' do
    describe '.with_partner_and_country' do
      let!(:japan) { create(:country, name: 'Japan') }
      let!(:france) { create(:country, name: 'France') }
      let!(:belgium) { create(:country, name: 'Belgium') }

      let!(:eau) { create(:partner, name: 'Eau') }
      let!(:mizu) { create(:partner, name: 'Mizu') }

      let!(:program1) { create(:program, partner: mizu, country: japan) }
      let!(:program2) { create(:program, partner: eau, country: france) }
      let!(:program3) { create(:program, partner: eau, country: belgium) }

      it 'returns the programs ordered by name, then id' do
        result = Program.with_partner_and_country

        expect(result).to eq [program3, program2, program1]
      end
    end
  end

  describe '#name' do
    let(:country) { Country.new(name: 'UK') }
    let(:partner) { Partner.new(name: 'Water') }

    before do
      program.country = country
      program.partner = partner
    end

    specify do
      expect(program.name).to eq 'Water – UK'
    end
  end
end
