module Import
  class RemoveDeletedSurveyResponsesJob < Job
    def self.queue
      :import
    end

    def self.perform
      RemoteMonitoring::SurveyImporting::Remover.new.remove_deleted
    end
  end
end
