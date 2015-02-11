module RemoteMonitoring
  module PostProcessor
    class SensorStorageClockUpdater
      def process(policy)
        project = Project.find_by(deployment_code: policy.deployment_code)
        Rails.logger.info(<<-LOG.strip_heredoc)
          Found project:#{project.id} located at #{project.latitude},#{project.longitude}
        LOG

        sensor = Sensor.find_by(project: project)
        return if sensor.nil?

        send_fsm_update(sensor)
      end

      def send_fsm_update(sensor)
        return if !Rails.env.production?

        require 'net/http'
        require 'uri'

        Rails.logger.info(<<-LOG.strip_heredoc)
          Found sensor:#{sensor.id}
          Updating FSM clock...
          Calculating offset...
        LOG

        offset = project.sensor_timezone_offset
        payload = self.build_payload(offset)

        Rails.logger.info(<<-LOG.strip_heredoc)
          Offset is #{offset}
          Base64 payload is #{payload}
          Sending request...
        LOG

        url = URI.parse("http://2.us.data.bodytrace.com:8080/1/device/#{sensor.device_id}/incomingmessage")
        req = Net::HTTP::Post.new(url.path)
        req.body = payload.to_json
        req.basic_auth ENV['BODYTRACE_USER'], ENV['BODYTRACE_PASSWORD']
        req.content_type = "application/json"
        resp = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }

        Rails.logger.info(<<-LOG.strip_heredoc)
          FSM Update Response: #{resp.code} - #{resp.msg}
        LOG

        if resp.code.to_i == 204
          Rails.logger.info(<<-LOG.strip_heredoc)
            Response is 204, FSM update sent, updating sensor storage_clock_fixed
          LOG
          sensor.storage_clock_fixed = true
          sensor.save
          Rails.logger.info(<<-LOG.strip_heredoc)
            storage_clock_fixed for #{sensor.imei} is now: #{sensor.storage_clock_fixed}
          LOG
        end

        resp.code
      end

      def build_payload(offset)
        offset_in_hours = offset.to_i
        offset_in_minutes = ((offset - offset.to_i)*60).to_i

        opcode = 0x02
        pad = 0x00
        seconds = 0x00
        minutes = offset_in_minutes.to_s(16)
        hours = offset_in_hours.to_s(16)

        ota = [opcode, pad, seconds, minutes, hours].map { |d| "#{d.to_s.rjust(2,'0').upcase}" }
        ota_string = ota.join(',').gsub(',','')
        hex = [ota_string].pack('H*')
        payload = Base64.strict_encode64(hex)

        { "data" => payload }
      end
    end
  end
end