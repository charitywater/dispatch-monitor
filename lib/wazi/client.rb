require 'digest'

module Wazi
  class Client < HttpClient
    base_uri ENV['WAZI_HOST']
    no_follow true

    def projects(params)
      get(projects_search_path(params), verify: verify?).parsed_response
    rescue RedirectionTooDeep
      []
    end

    def send_gps(body)
      response = post(send_gps_path, body: body, verify: verify?).body
      unless response.match(/\bpass\b/)
        Rails.logger.warn "Wazi rejected this POST: #{body}"
      end
    end

    private

    def verify?
      !(ENV['WAZI_VERIFY_SSL'] =~ /(false|f|no|n|0)$/i)
    end

    def send_gps_path
      '/gps_devices/submit_gps_data/'
    end

    def projects_search_path(params)
      '/' + search_path + to_query_in_order(query_params(params))
    end

    def query_params(params)
      # The Wazi api requires that the keys be presented in this order:
      # ?deployment_code=___&app_id=___&api_hash=___
      # api_hash algorithm described in #70696916
      params.merge(app_id: ENV['WAZI_APP_ID']).tap do |p|
        p[:api_hash] = api_hash(p)
      end
    end

    def api_hash(query_params)
      Digest::MD5.hexdigest(ENV['WAZI_SECRET'] + search_path + to_query_in_order(query_params))
    end

    def search_path
      'api/projects/search'
    end

    def to_query_in_order(query_params)
      '?' + query_params.map do |key, value|
        "#{key}=#{value}"
      end.join('&')
    end
  end
end
