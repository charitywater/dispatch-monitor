require 'spec_helper'

module Wazi
  describe Client do
    let(:client) { Client.new }

    describe '#projects' do
      let(:matcher) { %r{api/projects/search} }

      before do
        stub_request(:get, matcher)
          .with(query: {
            'deployment_code' => 'DEP1',
            'app_id' => ENV['WAZI_APP_ID'],
            'api_hash' => '5785ac49182750be676a36cb1c372d85',
          })
          .to_return(status: 200, body: [{id: 1, community_name: 'Project One', deployment_code: 'DEP1'}].to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'requests projects from the WAZI api' do
        expect(client.projects(deployment_code: 'DEP1')).to eq([
          {
            'id' => 1,
            'community_name' => 'Project One',
            'deployment_code' => 'DEP1'
          }
        ])
      end

      it 'does not follow redirects' do
        stub_request(:get, matcher)
          .with(query: {
            'deployment_code' => 'DEP1',
            'app_id' => ENV['WAZI_APP_ID'],
            'api_hash' => '5785ac49182750be676a36cb1c372d85',
          })
          .to_return(status: 302,  headers: { 'Content-Type' => 'text/html; charset=UTF-8', 'Location' => 'http://charitywater.org' })

        expect(client.projects(deployment_code: 'DEP1')).to eq([])
      end
    end

    describe '#send_gps' do
      let(:url) { ENV['WAZI_GPS_URL'] }
      let(:post_body) { 'gps data' }

      before do
        allow(Rails.logger).to receive(:warn)

        stub_request(:post, url).to_return(
          status: status,
          body: response_body
        )
      end

      context 'when Wazi returns success' do
        let(:status) { 200 }
        let(:response_body) { "xx: pass \nsomething else" }

        it 'does not log an error' do
          client.send_gps(post_body)

          expect(WebMock).to have_requested(:post, url).with(body: post_body)
          expect(Rails.logger).not_to have_received(:warn)
        end
      end

      context 'when Wazi does not return success' do
        let(:status) { 500 }
        let(:response_body) { 'fail compass' }

        it 'logs an error' do
          client.send_gps(post_body)

          expect(WebMock).to have_requested(:post, url).with(body: post_body)
          expect(Rails.logger).to have_received(:warn)
        end
      end
    end
  end
end
