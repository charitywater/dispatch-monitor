module Admin
  class ApplicationSettingsController < AdminController
    def edit
      @application_settings = ApplicationSettings.first_or_create
    end

    def update
      application_settings = ApplicationSettings.first_or_create

      if application_settings.update(application_settings_params)
        flash[:success] = t('.success')
      else
        flash[:alert] = t('.alert')
      end

      redirect_to edit_admin_application_settings_path
    end

    private

    def application_settings_params
      params.require(:application_settings)
        .permit(:sensors_affect_project_status)
    end
  end
end
