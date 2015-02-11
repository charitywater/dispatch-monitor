module Import
  class SourceObservationJob < Job
    def self.queue
      :import
    end

    def self.perform(response_hash)
      importer.import(response_hash)
    end

    def self.importer
      RemoteMonitoring::SurveyImporting::Webhook::Importer.new(
        survey_importer: RemoteMonitoring::SurveyImporting::SourceObservationImporter.new
      )
    end
  end
end
