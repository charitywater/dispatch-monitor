require 'spec_helper'

module Map
  describe Map::SensorsController do
    let(:account) { double(:account) }

    before do
      stub_logged_in(account)
      allow(controller).to receive(:authorize)
    end

    describe '#index' do
      let(:project) do
        double(
          :project,
          id: 5,
          sensor: sensor,
        )
      end
      let(:sensor) { build(:sensor, id: 6) }

      before do
        allow(Project).to receive(:find).with('5') { project }
        allow(project).to receive(:sensor) { sensor }
      end

      it 'authorizes the action' do
        get :index, project_id: 5

        expect(controller).to have_received(:authorize).with(project, :show?)
      end

      it 'renders the sensor as json' do
        get :index, project_id: 5

        json = JSON.parse(response.body)
        expect(json['project_id']).to eq 5
        expect(json['sensor']['id']).to eq 6
      end
    end
  end
end
