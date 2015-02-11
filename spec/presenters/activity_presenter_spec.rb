require 'spec_helper'

describe ActivityPresenter do
  let(:activity) { build(:activity, activity_type) }
  let(:presenter) { ActivityPresenter.new(activity) }

  describe '#as_json' do
    let(:activity_type) { :completed_construction }

    specify do
      json = presenter.as_json

      expect(json).to include(*%i(type happened_at url data manually_created_by generated_by_sensor))
      expect(json[:type]).to eq('completed_construction')
    end
  end

  describe '#url' do
    let(:activity_type) { :observation_survey_received }
    context 'for an activity without survey information' do
      before do
        activity.data = {}
      end

      specify do
        expect(presenter.url).to be_nil
      end
    end

    context 'for an activity with survey information' do
      before do
        activity.data = {
          'fs_survey_id' => 4,
          'fs_response_id' => 8,
        }
      end

      it 'links to fluid surveys' do
        expect(presenter.url).to eq 'https://charitywater.fluidsurveys.com/account/surveys/4/responses/?response=8'
      end
    end
  end

  describe '#data' do
    let(:activity_type) { :status_changed }

    before do
      activity.data = {
        'status' => Project.statuses[:inactive],
      }
    end

    it 'maps the project’s status enum int to string' do
      expect(presenter.data['status']).to eq 'inactive'
    end

    it 'does not overwrite the activity’s data' do
      presenter.data

      expect(activity.data['status']).to eq Project.statuses[:inactive]
    end
  end
end
