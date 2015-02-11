class DashboardController < ApplicationController
  def show
    @dashboard = Dashboard.new(DashboardFilterForm.new(filter_params))
  end
end
