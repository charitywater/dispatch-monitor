require 'spec_helper'

module FluidSurveys
  module Structure
    describe SensorRegistrationAFD1 do
      specify do
        expect(SensorRegistrationAFD1.survey_id).to eq 85707
      end

      let(:afd1) { SensorRegistrationAFD1.new(api) }
      let(:deployment_code_country) { 'LR' }
      let(:deployment_code_partner) { 'CON' }
      let(:deployment_code_quarter) { 'Q1' }
      let(:deployment_code_year) { '09' }
      let(:deployment_code_grant) { '036' }
      let(:deployment_code_point) { '020' }
      let(:error_code) { 'oH' }
      let(:device_id) { 'DVT999' }

      let(:api) do
        {
          'TBLwLK3wL8_0' => deployment_code_country,
          'TBLwLK3wL8_1' => deployment_code_partner,
          'TBLwLK3wL8_2' => deployment_code_quarter,
          'TBLwLK3wL8_3' => deployment_code_year,
          'TBLwLK3wL8_4' => deployment_code_grant,
          'TBLwLK3wL8_5' => deployment_code_point,
          '0oLTpi9Goh' => error_code,
          'CFDuMWqytJ' => device_id,
          '_id' => 11,
          '_created_at' => '2011-02-11T00:01:02.005',
        }
      end

      specify do
        expect(afd1.fs_response_id).to eq 11
      end

      specify do
        expect(afd1.fs_survey_id).to eq 85707
      end

      specify do
        expect(afd1.device_id).to eq 'DVT999'
      end

      specify do
        expect(afd1.error_code).to eq 'oH'
      end

      specify do
        expect(afd1.deployment_code).to eq 'LR.CON.Q1.09.036.020'
      end

      it 'strips the milliseconds off the submitted_at' do
        expect(afd1.submitted_at).to eq Time.zone.parse('2011-02-11T00:01:02')
      end
    end
  end
end
