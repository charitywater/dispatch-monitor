module Import
  class ProjectsController < AdminController
    def new
      @import_project = Import::Project.new
    end

    def create
      @import_project = Import::Project.new(project_imports_params)

      if @import_project.valid?
        enqueue(
          Import::ProjectJob,
          grant_deployment_code: @import_project.grant_deployment_codes,
          deployment_code: @import_project.deployment_codes
        )
        redirect_to projects_path,
          info: t('.success')
      else
        flash.now[:alert] = @import_project.errors.full_messages.to_sentence
        render :new
      end
    end

    private

    def project_imports_params
      params.require(:import_project).permit(:import_codes)
    end
  end
end
