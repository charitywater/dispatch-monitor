module Import
  class ProjectJob < BulkJob
    def self.import(*args)
      importer.import(*args)
    end

    def self.email_job
      Email::Import::ProjectResultJob
    end

    def self.importer
      RemoteMonitoring::WaziImporting::Importer.new
    end
  end
end
