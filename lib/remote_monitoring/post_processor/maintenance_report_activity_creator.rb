module RemoteMonitoring
  module PostProcessor
    class MaintenanceReportActivityCreator
      def process(policy)
        return unless policy.create_maintenance_report_activity?

        survey_response = policy.survey_response

        Activity.maintenance_report_received.find_or_initialize_by(
          happened_at: survey_response.submitted_at,
          project_id: survey_response.project_id,
        ).update(data: {
            fs_survey_id: survey_response.fs_survey_id,
            fs_response_id: survey_response.fs_response_id,
          })
      end
    end
  end
end
