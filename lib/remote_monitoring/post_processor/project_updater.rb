module RemoteMonitoring
  module PostProcessor
    class ProjectUpdater
      def process(policy)
        return unless policy.update_project_status?

        policy.project.update(status: policy.new_status)
      end
    end
  end
end
