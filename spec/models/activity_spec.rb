require 'spec_helper'

describe Activity do
  let(:activity) { Activity.new }

  describe 'validations' do
    specify do
      expect(activity).to validate_presence_of(:activity_type)
    end

    specify do
      expect(activity).to validate_presence_of(:happened_at)
    end

    specify do
      expect(activity).to validate_presence_of(:project_id)
    end

    it 'stores activity_type as an enum' do
      [
        :completed_construction,
        :observation_survey_received,
        :maintenance_report_received,
        :status_changed,
      ].each { |s| activity.activity_type = s }

      expect { activity.activity_type = :whatever }.to raise_error
    end
  end

  describe 'associations' do
    specify do
      expect(activity).to belong_to(:project)
    end

    specify do
      expect(activity).to belong_to(:sensor)
    end

    specify do
      expect(activity).to belong_to(:manually_created_by).class_name('Account')
    end
  end

  describe '.by_fs_survey_id' do
    let!(:first_activity) { create(:activity, data: { fs_survey_id: 1 }) }
    let!(:activity) { create(:activity, data: { fs_survey_id: 2 }) }

    specify do
      expect(Activity.by_fs_survey_id(2)).to eq [activity]
    end
  end

  describe '.by_fs_response_id' do
    let!(:first_activity) { create(:activity, data: { fs_response_id: 1 }) }
    let!(:activity) { create(:activity, data: { fs_response_id: 2 }) }

    specify do
      expect(Activity.by_fs_response_id(2)).to eq [activity]
    end
  end

  describe '.status_changed_to_needs_maintenance' do
    let!(:activity) { create(:activity, :status_changed_to_needs_maintenance) }

    before do
      create(:activity, :completed_construction)
      create(:activity, :status_changed_to_flowing)
    end

    it 'returns only the needs_maintenance activities' do
      expect(Activity.status_changed_to_needs_maintenance).to eq [activity]
    end
  end

  describe '.status_changed_to_flowing' do
    let!(:activity) { create(:activity, :status_changed_to_flowing) }

    before do
      create(:activity, :completed_construction)
      create(:activity, :status_changed_to_needs_maintenance)
    end

    it 'returns only the flowing activities' do
      expect(Activity.status_changed_to_flowing).to eq [activity]
    end
  end

  describe '.status_changed_to_inactive' do
    let!(:activity) { create(:activity, :status_changed_to_inactive) }

    before do
      create(:activity, :completed_construction)
      create(:activity, :status_changed_to_flowing)
    end

    it 'returns only the inactive activities' do
      expect(Activity.status_changed_to_inactive).to eq [activity]
    end
  end

  describe '.status_changed_to_needs_visit' do
    let!(:activity) { create(:activity, :status_changed_to_needs_visit) }

    before do
      create(:activity, :completed_construction)
      create(:activity, :status_changed_to_flowing)
    end

    it 'returns only the needs_visit activities' do
      expect(Activity.status_changed_to_needs_visit).to eq [activity]
    end
  end

  describe '.manually_created' do
    let(:account) { create(:account) }
    let!(:activity) { create(:activity, :status_changed_to_needs_visit, manually_created_by: account) }

    before do
      create(:activity, :completed_construction)
      create(:activity, :status_changed_to_flowing)
      create(:activity, :status_changed_to_needs_visit)
    end

    it 'returns only the manually created activities' do
      expect(Activity.manually_created).to eq [activity]
    end
  end

  describe '#generated_by_sensor?' do
    context 'when the data includes sensor: true' do
      before do
        activity.sensor_id = 1
      end

      specify do
        expect(activity).to be_generated_by_sensor
      end
    end

    context 'when the data does not include sensor: true' do
      before do
        activity.sensor_id = nil
      end

      specify do
        expect(activity).not_to be_generated_by_sensor
      end
    end
  end
end
