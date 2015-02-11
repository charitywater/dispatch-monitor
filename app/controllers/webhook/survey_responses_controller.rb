module Webhook
  class SurveyResponsesController < ApplicationController
    protect_from_forgery except: [:create]
    skip_before_action :authenticate_account!

    def create
      Webhook::SurveyResponse.new(survey_response_params).save

      render nothing: true, status: 200
    end

    private

    def survey_response_params
      params.except(:controller, :action).merge(webhook: true)
    end
  end
end
