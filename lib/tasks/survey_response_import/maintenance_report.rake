namespace :survey_response_import do
  desc 'Import maintenance report survey responses'
  task maintenance_report: :environment do |t, args|
    default_types = %w(maintenance_report_v02 test_maintenance_report_v02)
    survey_types = args.extras.present? ? args.extras : default_types

    RemoteMonitoring::JobQueue.enqueue(Import::MaintenanceReportsJob, survey_types)
  end
end
