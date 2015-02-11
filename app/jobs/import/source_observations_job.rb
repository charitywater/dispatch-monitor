module Import
  class SourceObservationsJob < BulkJob
    def self.import(source_observation_types, *_)
      Array(source_observation_types).map { |t| importer.import(t) }
    end

    def self.after_perform(_, maintenance_report_types = nil)
      if maintenance_report_types
        enqueue(Import::MaintenanceReportsJob, maintenance_report_types)
      end
    end

    def self.importer
      RemoteMonitoring::SurveyImporting::SourceObservationsImporter.new
    end

    def self.email_job
      Email::Import::SourceObservationsJob
    end
  end
end
