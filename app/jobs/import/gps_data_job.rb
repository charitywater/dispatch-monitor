module Import
  class GpsDataJob < Job
    def self.queue
      :import
    end

    def self.perform(xml)
      importer.import(xml)
    end

    def self.importer
      RemoteMonitoring::GpsImporting::Importer.new
    end
  end
end
