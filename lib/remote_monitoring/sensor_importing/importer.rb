module RemoteMonitoring
  module SensorImporting
    class Importer
      def initialize(post_processors = default_post_processors)
        @post_processors = post_processors
      end

      def import(data)
        Rails.logger.info <<-EOL.strip_heredoc
          Importing sensor data...
        EOL
        if data['imei'].to_s.first == "0"
          imei = data['imei'].to_s
        else
          imei = "0#{data['imei'].to_s}"
        end

        Rails.logger.info <<-EOL.strip_heredoc
          Looking for sensor #{imei}...
        EOL

        sensor = Sensor.find_or_create_by(imei: imei)
        sensor.save

        Rails.logger.info <<-EOL.strip_heredoc
          Found sensor #{sensor.imei}
        EOL

        if (data.has_key?("data") && !data.has_key?("values"))
          if data["data"].length < 856
            Rails.logger.info <<-EOL.strip_heredoc
              Detected unparsed sensor data - length of #{data["data"].length} is less than 856, not processing for sensor #{sensor.imei}
            EOL
          else
            Rails.logger.info <<-EOL.strip_heredoc
              Detected unparsed sensor data - creating new weekly log for sensor #{sensor.imei}
            EOL

            parser = SensorDataParser.new(data["data"])
            weekly_packet = parser.decode_weekly
            parsed_weekly_log = weekly_packet['values']['weeklyLog']

            week_started_at = Time.utc(
              "20#{parsed_weekly_log['gmtYear']}",
              data['gmtMonth'],
              data['gmtDay'],
              data['gmtHour'],
              data['gmtMinute'],
              data['gmtSecond'],
            )

            weekly_log = sensor.weekly_logs.create(
              red_flag: parsed_weekly_log['redFlag'],
              received_at: Time.at(data['ts'] / 1000.0).utc.to_datetime,
              week_started_at: week_started_at,
              data: weekly_packet,
            )

            Rails.logger.info <<-EOL.strip_heredoc
              Finished creating weekly log: #{weekly_log}
            EOL
            
            unless weekly_log.has_out_of_band_pair?
              policy = PostProcessor::SensorPolicy.new(sensor, weekly_log)

              post_processors.each do |processor|
                processor.process(policy)
              end
            end
          end
        elsif data.has_key?("values")
          if data["values"].has_key?("weeklyLog")
            Rails.logger.info <<-EOL.strip_heredoc
              Creating new weekly log for sensor #{sensor.imei}
            EOL
            # The "ts" field in the JSON is added by BodyTrace to the packet sent by the
            # sensor. It represents milliseconds since the epoch.
            weekly_log = sensor.weekly_logs.create(
              red_flag: weekly_log_field(data)['redFlag'],
              unit_id: weekly_log_field(data)['unitID'],
              week: week_field(data),
              received_at: Time.at(data['ts'] / 1000.0).utc.to_datetime,
              week_started_at: week_started_at(data),
              data: data,
            )

            Rails.logger.info <<-EOL.strip_heredoc
              Finished creating weekly log: #{weekly_log}
            EOL

            unless weekly_log.has_out_of_band_pair?
              policy = PostProcessor::SensorPolicy.new(sensor, weekly_log)

              post_processors.each do |processor|
                processor.process(policy)
              end
            end
          elsif data["values"].has_key?("finalAssembly")
            Rails.logger.info <<-EOL.strip_heredoc
              Detected final assembly packet
            EOL

            parsed_fa_packet = FinalAssemblyPacketParser.new(data)
            parsed_fa_packet.send_gmt_update unless sensor.clock_fixed?
          end
        end
      end

      private

      attr_reader :post_processors

      def default_post_processors
        [
          PostProcessor::ProjectUpdater.new,
          PostProcessor::ProjectStatusActivityCreator.new,
          PostProcessor::TicketCompleter.new,
          PostProcessor::SensorTicketCreator.new,
        ]
      end

      def week_started_at(data)
        data = weekly_log_field(data)
        Time.utc(
          "20#{data['gmtYear']}",
          data['gmtMonth'],
          data['gmtDay'],
          data['gmtHour'],
          data['gmtMinute'],
          data['gmtSecond'],
        )
      end

      def weekly_log_field(data)
        data['values']['weeklyLog']
      end

      def week_field(data)
        weekly_log_field(data)['week']
      end
    end
  end
end
