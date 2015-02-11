require 'spec_helper'

module Search
  describe Search::ProjectsController do
    before { stub_logged_in }

    describe '#index' do
      context 'valid params' do
        before do
          allow(Project).to receive(:within_bounds).with(1.0, 2.0, 3.0, 4.2)
            .and_return(projects)
        end

        context 'projects exist within bounds' do
          let(:projects) do
            [
              build(:project, :flowing, id: 1, latitude: 1.1, longitude: 2.2),
              build(:project, :flowing, id: 2, latitude: 2.1, longitude: 3.2),
            ]
          end

          it 'returns 200' do
            get :index, bounds: '1,2,3,4.2', format: :json

            expect(response).to be_success
          end

          it 'returns the projects' do
            get :index, bounds: '1,2,3,4.2', format: :json

            expect(response.body).to include('1.1')
            expect(response.body).to include('2.1')
            expect(response.body).to include('2.2')
            expect(response.body).to include('3.2')
            expect(response.body).not_to include('deployment_code')
          end
        end

        context 'no projects exist within bounds' do
          let(:projects) { [] }

          it 'returns 200' do
            get :index, bounds: '1,2,3,4.2', format: :json

            expect(response).to be_success
          end

          it 'returns an empty list' do
            get :index, bounds: '1,2,3,4.2', format: :json

            expect(response.body).to eq '[]'
          end
        end
      end

      context 'invalid params' do
        it 'returns 400' do
          get :index, format: :json
          expect(response).to be_bad_request

          get :index, bounds: '1,2,3,4,5', format: :json
          expect(response).to be_bad_request

          get :index, bounds: '1,2,3', format: :json
          expect(response).to be_bad_request
        end
      end

      context 'invalid format' do
        it 'returns 400' do
          get :index, format: :html

          expect(response).to be_bad_request
        end
      end
    end
  end
end
