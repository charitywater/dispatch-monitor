module Gps
  class ReceiveController < ApplicationController
    protect_from_forgery except: [:create]
    skip_before_action :authenticate_account!
    before_action :log_request_info

    def create
      enqueue(Import::GpsDataJob, request_body)

      prepare_response

      respond_to do |format|
        format.xml { render :action => @message_type == "stuMessages" ? "stu" : "prv" }
      end
    end

    private

    def log_request_info
      http_request_headers = request.headers.map do |header_name, header_value|
        if header_name.match(/^HTTP/)
          "#{header_name}: #{header_value}"
        end
      end.compact

      Rails.logger.info <<-EOL.strip_heredoc
      GPS info received:
        Params: #{params.except(:action, :controller).inspect}
        Headers:
          #{http_request_headers.join("\n          ")}
        Body: #{request_body}
      EOL
    end

    def prepare_response
      parsed_body = Nokogiri::XML(request_body)
      @message_type = parsed_body.element_children.first.name
      @message_id = (@message_type == "stuMessages") ? parsed_body.at_xpath('/stuMessages')['messageID'] : parsed_body.at_xpath('/prvmsgs')['prvMessageID']
      @delivered_at = Time.zone.now.utc
    end

    def request_body
      @request_body ||= request.body.read
    end
  end
end
