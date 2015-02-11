require 'spec_helper'

describe ProjectPresenter do
  let(:country) { build(:country, name: 'Fancy Country') }
  let(:partner) { build(:partner, name: 'Fancy Partner') }
  let(:project) { build(:project, community_name: 'Fancy Community', id: 123) }

  let(:presenter) { ProjectPresenter.new(project) }

  before do
    allow(project).to receive(:country) { country }
    allow(project).to receive(:partner) { partner }
  end

  describe '#title' do
    it 'returns the community name and the country' do
      expect(presenter.title).to eq 'Fancy Community – Fancy Country'
    end
  end

  describe '#partner' do
    it 'returns the partner name' do
      expect(presenter.partner).to eq 'Fancy Partner'
    end
  end

  describe '#status_tag' do
    it 'returns the titleized status' do
      expect(presenter.status_tag).to include 'Unknown'
    end
  end

  describe '#region' do
    context 'it has a region' do
      before do
        project.region = 'Fancy Region'
      end

      specify do
        expect(presenter.region).to eq 'Fancy Region'
      end
    end

    context 'it does not have a region' do
      before do
        project.region = nil
      end

      specify do
        expect(presenter.region).to eq 'N/A'
      end
    end
  end

  describe '#district' do
    context 'it has a district' do
      before do
        project.district = 'Fancy District'
      end

      specify do
        expect(presenter.district).to eq 'Fancy District'
      end
    end

    context 'it does not have a district' do
      before do
        project.district = nil
      end

      specify do
        expect(presenter.district).to eq 'N/A'
      end
    end
  end

  describe '#site_name' do
    context 'it has a site name' do
      before do
        project.site_name = 'Fancy Site'
      end

      specify do
        expect(presenter.site_name).to eq 'Fancy Site'
      end
    end

    context 'it does not have a site name' do
      before do
        project.site_name = nil
      end

      specify do
        expect(presenter.site_name).to eq 'N/A'
      end
    end
  end

  describe '#allows_new_ticket?' do
    context 'for flowing/unknown projects' do
      specify do
        %i(unknown flowing).each do |status|
          project.status = status
          expect(presenter.allows_new_ticket?).to be_truthy
        end
      end
    end

    context 'for other projects' do
      specify do
        Project.statuses.except(:unknown, :flowing).keys.each do |status|
          project.status = status
          expect(presenter.allows_new_ticket?).to be_falsey
        end
      end
    end
  end

  describe '#has_sensor?' do
    before do
      allow(project).to receive(:sensor) { sensor }
    end

    context 'when project does not have sensors' do
      let(:sensor) { nil }

      specify do
        expect(presenter.has_sensor?).to eq false
      end
    end

    context 'when project has sensors' do
      let(:sensor) { double(:sensor) }

      specify do
        expect(presenter.has_sensor?).to eq true
      end
    end
  end

  describe '#as_json' do
    before do
      project.status = :flowing
      allow(project).to receive(:sensor) { double(:sensor) }
    end

    specify do
      json = presenter.as_json
      expect(json).to include(*%i[
        beneficiaries community_name country
        completion_date deployment_code has_sensor id inventory_type latitude
        location_type longitude partner status title contact_name contact_email contact_phone_numbers
      ])

      expect(json[:id]).to eq(123)
      expect(json[:status]).to eq('flowing')
      expect(json[:has_sensor]).to eq(true)
    end
  end

  describe '#to_json' do
    before do
      project.status = :flowing
    end

    specify do
      json = presenter.to_json

      expect(json).to include('"title":"Fancy Community – Fancy Country"')
      expect(json).to include('"status":"flowing"')
    end
  end
end
