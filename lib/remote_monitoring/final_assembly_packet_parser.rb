module RemoteMonitoring
  class FinalAssemblyPacketParser
    def initialize(packet)
      @packet = packet
    end

    def calculate_time_difference
      values = @packet["values"]["finalAssembly"]

      time_difference = {}

      current_time = Time.at(@packet["ts"] / 1000).to_datetime.utc
      hour = (values["pm"] == 1) ? values["hour"] + 12 : values["hour"]
      year = values["year"].to_s(16)
      actual_year = "#{year[2]}#{year[3]}#{year[0]}#{year[1]}".to_i
      reported_time = DateTime.new(actual_year, values["month"], values["day"], hour, values["minute"], values["second"])

      difference_in_hours = current_time.hour - reported_time.hour
      difference_in_minutes_raw = current_time.minute - reported_time.minute
      difference_in_hours -= 1 if difference_in_minutes_raw < 0
      difference_in_minutes = 60 - difference_in_minutes_raw.abs

      time_difference["days"] = (current_time - reported_time).to_i
      time_difference["hours"] = difference_in_hours
      time_difference["minutes"] = difference_in_minutes

      # convert everything to hex
      time_difference["days"] = time_difference["days"].to_s(16)
      time_difference["hours"] = time_difference["hours"].to_s(16)
      time_difference["minutes"] = time_difference["minutes"].to_s(16)

      time_difference
    end

    def build_payload
      opcode = 0x01 # 01 is always the opcode for a gmt update
      seconds = 0x00
      minutes = calculate_time_difference['minutes']
      hours = calculate_time_difference['hours']
      days_msb = 0x00 # most significant byte
      days_lsb = calculate_time_difference['days']

      ota = [opcode, seconds, minutes, hours, days_msb, days_lsb].map { |d| "#{d.to_s.rjust(2,'0').upcase}" }
      ota_string = ota.join(',').gsub(',','')
      hex = [ota_string].pack('H*')
      payload = Base64.strict_encode64(hex)

      { "data" => payload }
    end

    def send_gmt_update
      return if !Rails.env.production?

      require 'net/http'
      require 'uri'

      Rails.logger.info(<<-LOG.strip_heredoc)
        Updating GMT time...
      LOG

      Rails.logger.info(<<-LOG.strip_heredoc)
        Calculating payload...
      LOG

      payload = build_payload

      Rails.logger.info(<<-LOG.strip_heredoc)
        Base64 payload is #{payload}
        Sending request...
      LOG

      imei = @packet['imei']

      url = URI.parse("http://2.us.data.bodytrace.com:8080/1/device/#{imei}/incomingmessage")
      req = Net::HTTP::Post.new(url.path)
      req.body = payload.to_json
      req.basic_auth ENV['BODYTRACE_USER'], ENV['BODYTRACE_PASSWORD']
      req.content_type = "application/json"
      resp = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }

      Rails.logger.info(<<-LOG.strip_heredoc)
        GMT Update Response: #{resp.code} - #{resp.msg}
      LOG

      if resp.code.to_i == 204
        Rails.logger.info(<<-LOG.strip_heredoc)
          Response is 204, GMT update sent, updating sensor clock_fixed
        LOG
        sensor = Sensor.find_by(imei: imei)
        sensor.clock_fixed = true
        sensor.save
        Rails.logger.info(<<-LOG.strip_heredoc)
          clock_fixed for #{sensor.imei} is now: #{sensor.clock_fixed}
        LOG
      end

      resp.code
    end
  end
end