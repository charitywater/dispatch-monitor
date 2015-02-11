require 'spec_helper'

describe SurveyResponse do
  let(:survey_response) { SurveyResponse.new }

  describe 'validations' do
    specify do
      expect(survey_response).to validate_presence_of(:fs_survey_id)
    end

    specify do
      expect(survey_response).to validate_presence_of(:fs_response_id)
    end

    specify do
      expect(survey_response).to validate_presence_of(:submitted_at)
    end

    specify do
      expect(survey_response).to validate_presence_of(:project_id)
    end

    specify do
      expect(survey_response).to validate_presence_of(:response)
    end

    specify do
      expect(survey_response).to validate_presence_of(:survey_type)
    end

    specify do
      expect(survey_response).to allow_value(
        :source_observation_v1,
        :test_source_observation_v1,
        :source_observation_v02,
        :test_source_observation_v02,
        :maintenance_report_v02,
        :test_maintenance_report_v02,
        'source_observation_v1',
        'test_source_observation_v1',
        'source_observation_v02',
        'test_source_observation_v02',
        'maintenance_report_v02',
        'test_maintenance_report_v02',
      ).for(:survey_type)

      expect(survey_response).not_to allow_value(
        'hello',
      ).for(:survey_type)
    end
  end

  describe 'assocations' do
    specify do
      expect(survey_response).to belong_to(:project)
    end

    specify do
      expect(survey_response).to have_one(:ticket).dependent(:destroy)
    end
  end

  describe '.since' do
    let!(:too_early) { create(:survey_response, submitted_at: 6.days.ago) }
    let!(:in_since) { create(:survey_response, submitted_at: 2.days.ago) }

    it 'returns the SurveyResponses created from since to now' do
      expect(SurveyResponse.since(4.days.ago)).to eq([in_since])
    end
  end

  describe '.source_observation' do
    let!(:so_v1) { create(:survey_response, :source_observation_v1) }
    let!(:so_v02) { create(:survey_response, :source_observation_v02) }
    let!(:so_test_v1) { create(:survey_response, :test_source_observation_v1) }
    let!(:so_test_v02) { create(:survey_response, :test_source_observation_v02) }
    let!(:mr_v02) { create(:survey_response, :maintenance_report_v02) }
    let!(:mr_test_v02) { create(:survey_response, :test_maintenance_report_v02) }

    it 'returns the source observation SurveyResponses' do
      expect(SurveyResponse.source_observation).to match_array(
        [so_v1, so_v02, so_test_v1, so_test_v02]
      )
    end
  end

  describe '.maintenance_report' do
    let!(:so_v1) { create(:survey_response, :source_observation_v1) }
    let!(:so_v02) { create(:survey_response, :source_observation_v02) }
    let!(:so_test_v1) { create(:survey_response, :test_source_observation_v1) }
    let!(:so_test_v02) { create(:survey_response, :test_source_observation_v02) }
    let!(:mr_v02) { create(:survey_response, :maintenance_report_v02) }
    let!(:mr_test_v02) { create(:survey_response, :test_maintenance_report_v02) }

    it 'returns the maintenance report SurveyResponses' do
      expect(SurveyResponse.maintenance_report).to match_array(
        [mr_v02, mr_test_v02]
      )
    end
  end

  describe '#fluid_surveys_url' do
    before do
      survey_response.fs_survey_id = 4
      survey_response.fs_response_id = 8
    end

    specify do
      expect(survey_response.fluid_surveys_url).to eq 'https://charitywater.fluidsurveys.com/account/surveys/4/responses/?response=8'
    end
  end

  describe '#source_observation?' do
    before do
      survey_response.survey_type = survey_type
    end

    context 'Source Observation V1' do
      let(:survey_type) { :source_observation_v1 }

      specify do
        expect(survey_response).to be_source_observation
      end
    end

    context 'Source Observation V02' do
      let(:survey_type) { :source_observation_v02 }

      specify do
        expect(survey_response).to be_source_observation
      end
    end

    context 'Test Source Observation V1' do
      let(:survey_type) { :test_source_observation_v1 }

      specify do
        expect(survey_response).to be_source_observation
      end
    end

    context 'Test Source Observation V02' do
      let(:survey_type) { :test_source_observation_v02 }

      specify do
        expect(survey_response).to be_source_observation
      end
    end

    context 'Maintenance Report V02' do
      let(:survey_type) { :maintenance_report_v02 }

      specify do
        expect(survey_response).not_to be_source_observation
      end
    end

    context 'Test Maintenance Report V02' do
      let(:survey_type) { :test_maintenance_report_v02 }

      specify do
        expect(survey_response).not_to be_source_observation
      end
    end
  end

  describe '#maintenance_report?' do
    before do
      survey_response.survey_type = survey_type
    end

    context 'Source Observation V1' do
      let(:survey_type) { :source_observation_v1 }

      specify do
        expect(survey_response).not_to be_maintenance_report
      end
    end

    context 'Source Observation V02' do
      let(:survey_type) { :source_observation_v02 }

      specify do
        expect(survey_response).not_to be_maintenance_report
      end
    end

    context 'Test Source Observation V1' do
      let(:survey_type) { :test_source_observation_v1 }

      specify do
        expect(survey_response).not_to be_maintenance_report
      end
    end

    context 'Test Source Observation V02' do
      let(:survey_type) { :test_source_observation_v02 }

      specify do
        expect(survey_response).not_to be_maintenance_report
      end
    end

    context 'Maintenance Report V02' do
      let(:survey_type) { :maintenance_report_v02 }

      specify do
        expect(survey_response).to be_maintenance_report
      end
    end

    context 'Test Maintenance Report V02' do
      let(:survey_type) { :test_maintenance_report_v02 }

      specify do
        expect(survey_response).to be_maintenance_report
      end
    end
  end

  describe '#flowing_water_answer' do
    let(:survey_response) { build(:survey_response, :source_observation_v02_with_data) }

    specify do
      expect(survey_response.flowing_water_answer).to eq 'Yes'
    end
  end

  describe '#consumable_water_answer' do
    let(:survey_response) { build(:survey_response, :source_observation_v02_with_data) }

    specify do
      expect(survey_response.consumable_water_answer).to eq 'Unknown / Unable to Answer'
    end
  end

  describe '#maintenance_visit_answer' do
    let(:survey_response) { build(:survey_response, :source_observation_v02_with_data) }

    specify do
      expect(survey_response.maintenance_visit_answer).to eq 'No'
    end
  end

  describe '#notes' do
    let(:survey_response) { build(:survey_response, :source_observation_v02_with_data) }

    specify do
      expect(survey_response.notes).to eq 'The local mechanic repaired it.'
    end
  end
end
