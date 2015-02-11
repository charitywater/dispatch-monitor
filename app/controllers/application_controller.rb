class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception

  before_action :authenticate_account!, unless: :devise_controller?
  before_action :configure_flashes

  add_flash_types :success, :info, :warning, :alert, :secondary

  rescue_from Pundit::NotAuthorizedError do
    if request.request_method_symbol == :get
      redirect_to root_path,
        warning: t('application.unauthorized')
    else
      head :forbidden
    end
  end

  private

  def enqueue(*args)
    RemoteMonitoring::JobQueue.enqueue(*args)
  end

  def configure_flashes
    flash.now[:success] = flash[:notice] if flash[:notice].present?
  end

  def after_sign_out_path_for(_)
    new_account_session_path
  end

  def pundit_user
    current_account
  end

  def user_for_paper_trail
    current_account
  end

  def filter_params
    (params[:filters] || {}).merge(current_account: current_account)
  end
end
