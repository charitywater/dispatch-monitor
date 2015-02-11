class AdminController < ApplicationController
  before_action :authorize_admin_action

  def authorize_admin_action
    self.policy = AdminPolicy.new(current_account)
    authorize :unused, :manage?
  end
end
