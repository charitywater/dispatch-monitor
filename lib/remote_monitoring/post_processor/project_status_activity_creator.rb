module RemoteMonitoring
  module PostProcessor
    class ProjectStatusActivityCreator
      def process(policy)
        return unless policy.create_status_activity?

        activity_query = {
          happened_at: policy.happened_at,
          project_id: policy.project.id,
        }

        activity_data = {
          data: {
            status: Project.statuses[policy.new_status]
          }
        }.merge(sensor: policy.try(:sensor))

        Activity
          .status_changed
          .find_or_create_by(activity_query)
          .update(activity_data)
      end
    end
  end
end
