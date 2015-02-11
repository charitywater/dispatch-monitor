module Import
  class SensorJob < Job
    def self.queue
      :import
    end

    def self.perform(job_data_id)
      job_data = JobData.find(job_data_id)

      importer.import(job_data.data)
    end

    private

    def self.importer
      RemoteMonitoring::SensorImporting::Importer.new
    end
  end
end
