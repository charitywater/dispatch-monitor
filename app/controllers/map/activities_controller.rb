module Map
  class ActivitiesController < ApplicationController
    def index
      project = Project.find(params[:project_id])
      authorize project, :show?

      activities = project
        .activities
        .order(happened_at: :desc, activity_type: :desc)
        .includes(:manually_created_by)
        .map do |activity|
        ActivityPresenter.new(activity)
      end

      render json: {
        activities: activities,
        project_id: project.id,
      }
    end
  end
end
