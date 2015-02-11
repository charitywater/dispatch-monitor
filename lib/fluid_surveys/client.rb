module FluidSurveys
  class Client < HttpClient
    base_uri ENV['FLUID_SURVEYS_HOST']

    def initialize(resolver = FluidSurveys::Structure::Resolver.new)
      @resolver = resolver
    end

    def survey_response(options)
      options.symbolize_keys!
      survey_id = options.fetch(:fs_survey_id)
      survey_response_id = options.fetch(:fs_response_id)

      get(
        survey_response_path(survey_id, survey_response_id),
        basic_auth: auth,
      ).parsed_response.try(:[], 'responses').try(:first)
    end

    def responses(survey_id)
      Enumerator.new do |e|
        offset = 0

        begin
          api_response = get(
            survey_responses_path(survey_id),
            basic_auth: auth,
            query: { offset: offset, limit: limit, include_labels: true, _completed: 1 }
          ).parsed_response

          offset += api_response['count']

          api_response['responses'].each { |r| e << r }
        end while !short_circuit? && api_response['count'] != 0
      end
    end

    def webhooks
      get(webhooks_path, basic_auth: auth).parsed_response
    end

    def subscribe_to_webhook(
      callback_url: callback_url,
      survey_type: nil,
      event: 'response_complete'
    )
      survey_id = resolver.resolve(survey_type).survey_id
      post(subscribe_webhook_path, basic_auth: auth, body: {
        event: event,
        subscription_url: callback_url,
        survey: survey_id,
      })
    end

    def unsubscribe_from_webhook(callback_url)
      post(unsubscribe_webhook_path, basic_auth: auth, body: {
        subscription_url: callback_url,
      })
    end

    private

    attr_reader :resolver

    def auth
      {
        username: ENV['FLUID_SURVEYS_USER'],
        password: ENV['FLUID_SURVEYS_PASSWORD']
      }
    end

    def survey_responses_path(survey_id)
      "/api/v2/surveys/#{survey_id}/responses/"
    end

    def survey_response_path(survey_id, survey_response_id)
      "/api/v2/surveys/#{survey_id}/responses/#{survey_response_id}/"
    end

    def webhooks_path
      '/api/v2/webhooks/'
    end

    def subscribe_webhook_path
      '/api/v2/webhooks/subscribe/'
    end

    def unsubscribe_webhook_path
      '/api/v2/webhooks/unsubscribe/'
    end

    def limit
      ENV['FLUID_SURVEYS_LIMIT'] || 200
    end

    def short_circuit?
      ENV['TEST_ONLY__FLUID_SURVEYS_CLIENT_SKIP_PAGING'].present?
    end
  end
end
