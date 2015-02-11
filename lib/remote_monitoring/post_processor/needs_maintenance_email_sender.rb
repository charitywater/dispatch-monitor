module RemoteMonitoring
  module PostProcessor
    class NeedsMaintenanceEmailSender
      def process(policy)
        return unless policy.send_needs_maintenance_email?

        RemoteMonitoring::JobQueue.enqueue(
          Email::ProjectNeedsMaintenanceJob,
          policy.survey_response.id
        )
      end
    end
  end
end
