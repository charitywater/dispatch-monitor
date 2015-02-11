namespace :survey_response_import do
  desc 'Import Source Observation, then Maintenance Report survey responses'
  task both_types: :environment do |t, args|
    survey_types = args.extras.map { |a| a.split(':') }

    RemoteMonitoring::JobQueue.enqueue(Import::SourceObservationsJob, *survey_types)
  end
end
