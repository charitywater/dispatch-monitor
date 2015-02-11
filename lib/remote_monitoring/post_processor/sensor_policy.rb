module RemoteMonitoring
  module PostProcessor
    class SensorPolicy
      attr_reader :sensor, :old_status, :weekly_log, :application_settings

      delegate :project, to: :sensor
      delegate :normal_flow?, to: :weekly_log
      delegate :sensors_affect_project_status?, to: :application_settings

      def initialize(sensor, weekly_log)
        @sensor = sensor
        @old_status = sensor.project.status.to_sym
        @application_settings = ApplicationSettings.first_or_create

        @weekly_log = weekly_log
      end

      def happened_at
        weekly_log.received_at
      end

      def new_status
        if normal_flow?
          if old_status == :needs_maintenance
            if needs_maintenance_from_sensor?
              :flowing
            else
              :needs_visit
            end
          elsif %i(flowing unknown).include?(old_status)
            :flowing
          else
            :needs_visit
          end
        else
          if old_status == :inactive
            :inactive
          else
            :needs_maintenance
          end
        end
      end

      def status_changed?
        old_status != new_status
      end

      def update_project_status?
        status_changed? && sensors_affect_project_status?
      end
      alias_method :create_status_activity?, :update_project_status?

      def create_new_ticket?
        update_project_status? &&
          ticketable_statuses.include?(new_status)
      end

      def complete_previous_tickets?
        update_project_status? && (
          (old_status == :needs_maintenance && %i(needs_visit flowing).include?(new_status)) ||
          (old_status == :needs_visit && new_status == :needs_maintenance)
        )
      end

      def ticket_has_due_date?
        new_status == :needs_maintenance
      end

      def flowing_water_answer
        if status_changed?
          if new_status == :needs_maintenance
            'No'
          elsif new_status == :needs_visit
            'Yes'
          end
        end
      end

      def maintenance_visit_answer
        'Yes' if create_new_ticket? && old_status != :inactive
      end

      private

      def ticketable_statuses
        %i(needs_maintenance needs_visit)
      end

      def needs_maintenance_from_sensor?
        project
          .activities.status_changed_to_needs_maintenance
          .order(happened_at: :desc)
          .first
          .generated_by_sensor?
      end
    end
  end
end
