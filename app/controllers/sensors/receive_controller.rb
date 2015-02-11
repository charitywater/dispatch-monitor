module Sensors
  class ReceiveController < ApplicationController
    protect_from_forgery except: [:create]
    skip_before_action :authenticate_account!

    def create
      sensor = Sensor.find_or_create_by(imei: imei)

      if sensor
        job_data = JobData.create(data: parsed_body)
        enqueue(Import::SensorJob, job_data.id)

        log_success
      else
        log_failure
      end

      render json: {success: 'ok'}
    end

    private

    def parsed_body
      @parsed_body ||= JSON.parse(json_body)
    end

    def json_body
      @json_body ||= request.body.read.html_safe
    end

    def device_id
      parsed_body['deviceId'].to_s
    end

    def imei
      if parsed_body['imei'].to_s.first == "0"
        parsed_body['imei'].to_s
      else
        "0#{parsed_body['imei'].to_s}"
      end
    end

    def log_success
      Rails.logger.info <<-EOL.strip_heredoc
        Valid BodyTrace request received:
          IMEI #{imei} has been updated.
          Received body: #{json_body}
      EOL
    end

    def log_failure
      Rails.logger.info <<-EOL.strip_heredoc
      Invalid BodyTrace request received:
        IMEI #{imei} was not found in the database.
        Received body: #{json_body}
      EOL
    end
  end
end
