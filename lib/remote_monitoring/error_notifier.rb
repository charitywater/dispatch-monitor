module RemoteMonitoring
  class ErrorNotifier
    def self.notify(e)
      Raven.capture_exception(e)
    end
  end
end
