namespace :survey_response_import do
  desc 'Import source observation survey responses'
  task source_observation: :environment do |t, args|
    default_types = %w(source_observation_v1 source_observation_v02 test_source_observation_v02)
    survey_types = args.extras.present? ? args.extras : default_types

    RemoteMonitoring::JobQueue.enqueue(Import::SourceObservationsJob, survey_types)
  end
end
