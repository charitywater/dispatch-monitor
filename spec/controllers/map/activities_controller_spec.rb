require 'spec_helper'

module Map
  describe Map::ActivitiesController do
    let(:account) { double(:account) }

    before do
      stub_logged_in(account)
      allow(controller).to receive(:authorize)
    end

    describe '#index' do
      let(:project) { build(:project, id: 5) }

      let(:activities) { double(:activities) }
      let(:ordered_activities) { double(:ordered_activities) }
      let(:activities_and_accounts) do
        [
          build(:activity, :completed_construction),
          build(:activity, :observation_survey_received),
        ]
      end

      before do
        allow(Project).to receive(:find).with('5') { project }
        allow(project).to receive(:activities) { activities }
        allow(activities).to receive(:order)
          .with(happened_at: :desc, activity_type: :desc) { ordered_activities }
        allow(ordered_activities).to receive(:includes)
          .with(:manually_created_by) { activities_and_accounts }
      end

      it 'authorizes the action' do
        get :index, project_id: 5

        expect(controller).to have_received(:authorize).with(project, :show?)
      end

      it 'renders the activities as json' do
        get :index, project_id: 5

        json = JSON.parse(response.body)
        expect(json['activities'].map { |a| a['type'] })
          .to eq %w(completed_construction observation_survey_received)
        expect(json['project_id']).to eq 5
      end
    end
  end
end
