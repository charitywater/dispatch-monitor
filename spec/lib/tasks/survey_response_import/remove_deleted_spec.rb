require 'spec_helper'

describe 'rake survey_response_import:remove_deleted' do
  before do
    allow(RemoteMonitoring::JobQueue).to receive(:enqueue)

    Rake::Task['survey_response_import:remove_deleted'].reenable
  end

  it 'enqueues the bulk survey job with the source observation v1 survey by default' do
    Rake::Task['survey_response_import:remove_deleted'].invoke

    expect(RemoteMonitoring::JobQueue).to have_received(:enqueue).with(
      Import::RemoveDeletedSurveyResponsesJob,
    )
  end
end
