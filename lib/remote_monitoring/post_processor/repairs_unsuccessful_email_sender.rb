module RemoteMonitoring
  module PostProcessor
    class RepairsUnsuccessfulEmailSender
      def process(policy)
        return unless policy.send_repairs_unsuccessful_email?

        RemoteMonitoring::JobQueue.enqueue(
          Email::RepairsUnsuccessfulJob,
          policy.survey_response.id
        )
      end
    end
  end
end
