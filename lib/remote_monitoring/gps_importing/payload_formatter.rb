module RemoteMonitoring
  module GpsImporting
    class PayloadFormatter < SimpleDelegator
      def message_time_gmt
        I18n.l(payload.message_time_gmt, format: :gps)
      end

      def latitude
        '%.6f' % payload.latitude
      end

      def longitude
        '%.6f' % payload.longitude
      end

      def to_s
        [
          message_time_gmt,
          esn,
          unit_name,
          message_type,
          sequence_number,
          esn,
          unit_name,
          message_time_gmt,
          message_type_or_subtype,
          battery_condition,
          gps_data,
          missed_alarm,
          field_12,
          longitude,
          latitude,
          message_trigger,
          message_trigger_state,
          inputs,
          alarms,
          moving,
          gps_quality,
        ].join("\t")
      end

      private

      alias_method :payload, :__getobj__

      def ignored_field
        'xx'
      end

      [
        :unit_name,
        :message_type,
        :sequence_number,
        :unit_name,
        :battery_condition,
        :gps_data,
        :missed_alarm,
        :field_12,
        :message_trigger,
        :message_trigger_state,
        :inputs,
        :alarms,
        :moving,
      ].each do |method|
        alias_method method, :ignored_field
      end
    end
  end
end
