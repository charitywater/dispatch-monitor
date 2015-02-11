module RemoteMonitoring
  module PostProcessor
    class SurveyPolicy
      attr_reader :survey_response, :old_status

      delegate :project, :structure, :maintenance_report?, :source_observation?, to: :survey_response
      delegate :repairs_successful?, :from_webhook?, to: :structure

      def initialize(survey_response)
        @survey_response = survey_response
        @old_status = survey_response.project.status.to_sym
      end

      def happened_at
        survey_response.submitted_at
      end

      def create_maintenance_report_activity?
        maintenance_report_processable?
      end

      def maintenance_report_processable?
        maintenance_report? &&
          project_can_receive_maintenance_report?
      end

      def create_source_observation_activity?
        source_observation?
      end

      def complete_previous_tickets?
        maintenance_report_processable? &&
          !(try_repairs_again? && old_status == :needs_maintenance)
      end

      def create_new_ticket?
        %i(needs_visit needs_maintenance).include?(new_status) && (
          source_observation? || complete_previous_tickets?
        )
      end

      def ticket_has_due_date?
        new_status == :needs_maintenance
      end

      def send_repairs_unsuccessful_email?
        from_webhook? && maintenance_report_processable? && try_repairs_again?
      end

      def send_needs_maintenance_email?
        from_webhook? &&
          new_status == :needs_maintenance && (
            source_observation? || (
              maintenance_report_processable? &&
              repairs_successful?
            )
        )
      end

      def update_project_status?
        status_changed? && (
          source_observation? || maintenance_report_processable?
        ) && !status_changed_in_the_future?
      end

      def create_status_activity?
        update_project_status?
      end

      def status_changed?
        old_status != new_status
      end

      def project_can_receive_maintenance_report?
        %i(needs_visit needs_maintenance).include?(old_status)
      end

      def new_status
        if source_observation?
          structure.status
        elsif maintenance_report_processable?
          if repairs_successful?
            structure.status
          elsif structure.now_inactive?
            :inactive
          else
            :needs_maintenance
          end
        else
          old_status
        end
      end

      private

      def try_repairs_again?
        !repairs_successful? && (new_status != :inactive)
      end

      def status_changed_in_the_future?
        project.activities
          .status_changed
          .where('happened_at > ?', survey_response.submitted_at)
          .any?
      end
    end
  end
end
