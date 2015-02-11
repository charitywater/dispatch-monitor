module Import
  class SurveysController < AdminController
    def new
      @import_survey = Import::Survey.new
    end

    def create
      @import_survey = Import::Survey.new(survey_params)
      if @import_survey.save
        redirect_to projects_path,
          info: t('.success')
      else
        flash.now[:alert] = t('.alert')
        render :new
      end
    end

    private

    def survey_params
      params.require(:import_survey).permit(:survey_type)
    end
  end
end
