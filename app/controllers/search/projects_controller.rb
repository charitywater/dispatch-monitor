module Search
  class ProjectsController < ApplicationController
    before_action :validate_bounds

    def index
      project_list = Search::ProjectList.new(FilterForm.new(current_account: current_account), bounds)

      respond_to do |format|
        format.json { render json: project_list.items, status: 200 }
      end
    end

    private

    def bounds
      @bounds ||= (params[:bounds] || '').split(',').map(&:to_f)
    end

    def validate_bounds
      if bounds.size != 4
        render nothing: true, status: 400
      end
    end
  end
end
