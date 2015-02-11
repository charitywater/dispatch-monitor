module Map
  class SensorsController < ApplicationController
    def index
      project = Project.find(params[:project_id])
      authorize project, :show?

      render json: {
        sensor: Map::SensorPresenter.new(project.sensor),
        project_id: project.id,
      }
    end
  end
end
