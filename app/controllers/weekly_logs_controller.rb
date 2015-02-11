class WeeklyLogsController < ApplicationController
  before_action :set_weekly_log, only: [:show, :edit, :update, :destroy]

  def index
    @weekly_logs = WeeklyLogList.new(FilterForm.new(filter_params))
  end

  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_weekly_log
      @weekly_log = WeeklyLog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def weekly_log_params
      params.require(:weekly_log).permit(:show, :index)
    end
end
