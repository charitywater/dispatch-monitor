namespace :survey_response_import do
  desc 'Remove survey responses deleted from FluidSurveys'
  task remove_deleted: :environment do |t|
    RemoteMonitoring::JobQueue.enqueue(Import::RemoveDeletedSurveyResponsesJob)
  end
end
