require 'spec_helper'

describe SensorRegistrationResponse do
  let(:sensor_registration_response) { SensorRegistrationResponse.new }

  # describe '.since' do
  #   let!(:too_early) { create(:survey_response, submitted_at: 6.days.ago) }
  #   let!(:in_since) { create(:survey_response, submitted_at: 2.days.ago) }

  #   it 'returns the SurveyResponses created from since to now' do
  #     expect(SurveyResponse.since(4.days.ago)).to eq([in_since])
  #   end
  # end

  describe '.sensor_registration' do
    let!(:sr_afd1) { create(:sensor_registration_response, :sensor_registration_afd1) }

    it 'returns the SensorRegistrationResponses' do
      expect(SensorRegistrationResponse.sensor_registration).to match_array(
        [sr_afd1]
      )
    end
  end

  describe '#fluid_surveys_url' do
    before do
      sensor_registration_response.fs_survey_id = 4
      sensor_registration_response.fs_response_id = 8
    end

    specify do
      expect(sensor_registration_response.fluid_surveys_url).to eq 'https://charitywater.fluidsurveys.com/account/surveys/4/responses/?response=8'
    end
  end

  describe '#sensor_registration?' do
    before do
      sensor_registration_response.survey_type = survey_type
    end

    context 'Sensor Registration AFD-1' do
      let(:survey_type) { :sensor_registration_afd1 }

      specify do
        expect(sensor_registration_response).to be_sensor_registration
      end
    end
  end
end
