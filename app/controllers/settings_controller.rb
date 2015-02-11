class SettingsController < ApplicationController
  def edit
    @account = current_account
  end

  def update
    if current_account.update(account_params)
      sign_in(current_account, bypass: true)
      redirect_to edit_settings_path,
        success: t('.success')
    else
      flash.now[:alert] = t('.alert')
      render :edit
    end
  end

  private

  def account_params
    params.require(:account)
      .permit(:name, :email, :password, :timezone, :weekly_subscription).tap do |p|
        p[:name].try(:strip!)
        p[:email].try(:strip!)
        p.delete(:password) if p[:password].blank?
      end
  end
end
