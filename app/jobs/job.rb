class Job
  def self.enqueue(*args)
    RemoteMonitoring::JobQueue.enqueue(*args)
  end
end
