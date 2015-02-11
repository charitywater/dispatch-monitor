require 'spec_helper'

module FluidSurveys
  describe Client do
    let(:client) { Client.new }
    let(:user) { ENV['FLUID_SURVEYS_USER'] }
    let(:password) { ENV['FLUID_SURVEYS_PASSWORD'] }
    let(:base_url) { "https://#{CGI.escape(user)}:#{password}@charitywater.fluidsurveys.com/api/v2" }

    describe '#survey_response' do
      let(:url) { "#{base_url}/surveys/#{survey_id}/responses/#{survey_response_id}/" }
      let(:survey_id) { 51399 }
      let(:survey_response_id) { 11 }
      let(:survey_response) do
        {
          'icJ0bt2hs1' => 'LR.CON.Q1.09.036.020',
          'hqSVwuhttr' => false,
          'qVreqGQpLA' => 0,
          '_id' => 11,
          '_created_at' => '2011-02-11T00:01:02',
        }
      end

      let(:data) { { fs_survey_id: survey_id, fs_response_id: survey_response_id } }

      before do
        stub_request(:get, url)
          .to_return(
            status: 200,
            headers: { 'Content-Type' => 'application/json' },
            body: {
              count: 1,
              responses: [survey_response]
            }.to_json,
        )
      end

      it 'returns the parsed response' do
        expect(client.survey_response(data)).to eq survey_response
      end
    end

    describe '#responses' do
      let(:survey_id) { 51399 }
      let(:url) { "#{base_url}/surveys/#{survey_id}/responses/" }
      let(:limit) { ENV['FLUID_SURVEYS_LIMIT'] }

      let(:survey_responses) do
        [
          {
            'icJ0bt2hs1' => 'LR.CON.Q1.09.036.020',
            'hqSVwuhttr' => false,
            'qVreqGQpLA' => 0,
            '_id' => 11,
            '_created_at' => '2011-02-11T00:01:02',
          },
          {
            'icJ0bt2hs1' => 'LR.CON.Q1.09.036.037',
            'hqSVwuhttr' => false,
            'qVreqGQpLA' => 1,
            '_id' => 12,
            '_created_at' => '2011-02-12T00:01:02',
          },
          {
            'icJ0bt2hs1' => 'LR.CON.Q1.09.036.036',
            'hqSVwuhttr' => true,
            'qVreqGQpLA' => 0,
            '_id' => 13,
            '_created_at' => '2011-02-13T00:01:02',
          },
          {
            'icJ0bt2hs1' => '',
            'hqSVwuhttr' => true,
            'qVreqGQpLA' => 0,
            '_id' => 13,
            '_created_at' => '2011-02-14T00:01:02',
          },
        ]
      end

      before do
        stub_request(:get, url)
          .with(query: { offset: 0, limit: limit, include_labels: 'true', _completed: 1 })
          .to_return(
            status: 200,
            headers: { 'Content-Type' => 'application/json' },
            body: {
              count: survey_responses.count,
              responses: survey_responses
            }.to_json,
        )

        stub_request(:get, url)
          .with(query: { offset: survey_responses.count, limit: limit, include_labels: 'true', _completed: 1 })
          .to_return(
            status: 200,
            headers: { 'Content-Type' => 'application/json' },
            body: {
              count: 0,
              responses: []
            }.to_json,
        )
      end

      it 'returns the responses from the FS API' do
        expect(client.responses(survey_id).to_a).to eq survey_responses
      end
    end

    describe 'webhooks' do
      let(:callback_url) { 'http://example.com' }

      before do
        stub_request(:post, /.*charitywater\.fluidsurveys.*/)
      end

      describe '#webhooks' do
        let(:url) { "#{base_url}/webhooks/" }

        before do
          stub_request(:get, url)
            .to_return(
              status: 200,
              headers: { 'Content-Type' => 'application/json' },
              body: {
                count: 1,
                webhooks: [{ hello: 'there' }]
              }.to_json,
          )
        end

        it 'returns the webhooks from the FS API' do
          expect(client.webhooks).to eq(
            'count' => 1,
            'webhooks' => [{ 'hello' => 'there' }]
          )
        end
      end

      describe '#subscribe_to_webhook' do
        it "adds a callback url for the survey's response_complete event to the FS API" do
          client.subscribe_to_webhook(callback_url: callback_url, survey_type: :test_source_observation_v1)

          expect(WebMock).to have_requested(
            :post,
            "#{base_url}/webhooks/subscribe/"
          ).with(body: {
            event: 'response_complete',
            subscription_url: callback_url,
            survey: FluidSurveys::Structure::TestSourceObservationV1.survey_id
          }.to_query)
        end
      end

      describe '#unsubscribe_from_webhook' do
        it "removes the callback url from the survey's webhooks" do
          client.unsubscribe_from_webhook(callback_url)

          expect(WebMock).to have_requested(
            :post,
            "#{base_url}/webhooks/unsubscribe/"
          ).with(body: {
            subscription_url: callback_url
          })
        end
      end
    end
  end
end
