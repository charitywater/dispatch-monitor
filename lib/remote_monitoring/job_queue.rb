module RemoteMonitoring
  class JobQueue
    def self.enqueue(job, *args)
      Resque.enqueue(job, *args)
    end

    def self.enqueue_in(seconds, job, *args)
      Resque.enqueue_in(seconds, job, *args)
    end
  end
end
