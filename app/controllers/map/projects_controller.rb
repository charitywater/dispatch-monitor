module Map
  class ProjectsController < ApplicationController
    def show
      full_width_nav_bar

      project = Project.find(params[:id])
      presented_project = ProjectPresenter.new(project)
      filter_form = FilterForm.new(filter_params)
      @map = ProjectMap.new(filter_form, presented_project)

      authorize project, :show?

      respond_to do |format|
        format.html
        format.json { render json: presented_project }
      end
    end

    private

    def full_width_nav_bar
      @navbar_class = 'expand-full'
    end
  end
end
