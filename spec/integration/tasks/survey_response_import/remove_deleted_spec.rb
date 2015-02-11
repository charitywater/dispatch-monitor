require 'spec_helper'

describe 'rake survey_response_import:remove_deleted', :vcr do
  let(:survey_id) { FluidSurveys::Structure::SourceObservationV1.survey_id }

  before do
    @fluid_surveys_response_limit = ENV['FLUID_SURVEYS_LIMIT']
    ENV['FLUID_SURVEYS_LIMIT'] = '9'
    ENV['TEST_ONLY__FLUID_SURVEYS_CLIENT_SKIP_PAGING'] = 'true'
  end

  after do
    ENV['FLUID_SURVEYS_LIMIT'] = @fluid_surveys_response_limit
    ENV['TEST_ONLY__FLUID_SURVEYS_CLIENT_SKIP_PAGING'] = nil
  end

  it 'removes only the survey responses deleted from FluidSurveys' do
    Rake::Task['survey_response_import:source_observation'].reenable
    Rake::Task['survey_response_import:source_observation'].invoke(:source_observation_v1)

    non_deleted_survey_response_count = SurveyResponse.count
    non_deleted_activity_count = Activity.count

    create(:survey_response, fs_survey_id: survey_id, fs_response_id: -12345)
    create(:activity, :observation_survey_received, data: { fs_survey_id: survey_id, fs_response_id: -12345 })

    Rake::Task['survey_response_import:remove_deleted'].reenable
    Rake::Task['survey_response_import:remove_deleted'].invoke

    expect(SurveyResponse.count).to eq non_deleted_survey_response_count
    expect(Activity.count).to eq non_deleted_activity_count
  end
end
