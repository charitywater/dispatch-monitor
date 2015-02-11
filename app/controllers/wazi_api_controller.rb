class WaziApiController < ApplicationController
  def proxy
    project = wazi.projects(wazi_params)

    render json: project
  end

  private

  def wazi
    Wazi::Client.new
  end

  def wazi_params
    params.except(
      :action,
      :controller,
      :path,
      :api_hash,
      :app_id
    )
  end
end
