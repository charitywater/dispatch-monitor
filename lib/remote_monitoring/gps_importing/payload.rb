module RemoteMonitoring
  module GpsImporting
    class Payload
      def initialize(node)
        @node = node
      end

      def message_time_gmt
        unix_time = node.at_xpath('unixTime').text
        Time.zone.at(unix_time.to_i).to_datetime
      end

      def esn
        node.at_xpath('esn').text.sub('0-', '')
      end

      MESSAGE_TYPE    = 0x030000000000000000
      MESSAGE_SUBTYPE = 0x00000000000000F000
      def message_type_or_subtype
        if mask & MESSAGE_TYPE != 0
          'Not Type 0 Standard Message'
        elsif mask & MESSAGE_SUBTYPE != 0
          'Not Location Subtype'
        else
          'Location'
        end
      end

      VALID_ESNS = %w(
        1250133
        1247106
        1248964
        1227975
        1227980
        1248779
        1227634
        1248507
        1248985
        1249509
        1223278
        1227997
        1227859
        1231421
        1224448
        1224451
        1224375
        1228859
        1231048
        1226680
        1227749
        1249492
      )
      def valid?
        VALID_ESNS.include? esn
      end

      def invalid?
        !valid?
      end

      GPS_QUALITY = 1 << 7
      def gps_quality
        mask & GPS_QUALITY == GPS_QUALITY ? 'Reduced' : 'High'
      end

      LATITUDE = 0xFFFFFF0000000000
      LATITUDE_OFFSET = 40
      def latitude
        counts = (mask & LATITUDE) >> LATITUDE_OFFSET
        counts_to_degrees(counts, :latitude)
      end

      LONGITUDE = 0xFFFFFF0000
      LONGITUDE_OFFSET = 16
      def longitude
        counts = (mask & LONGITUDE) >> LONGITUDE_OFFSET
        counts_to_degrees(counts, :longitude)
      end

      def counts_to_degrees(counts, coordinate)
        # GlobalStar represents latitude and longitude as a 24-bit signed binary number
        # 0x80000 is the 1 sign bit, 0x7FFFFF are the 23 data bits.
        # A 23-bit number can be in the range of 0 to 8,338,607, which
        # represents 0 to either 90 degrees latitude or 180 degrees longitude.
        max_data_bits = 2**23
        degrees_in_coordinate = { latitude: 90.0, longitude: 180.0 }[coordinate]
        counts_per_degree = max_data_bits / degrees_in_coordinate

        degrees = counts / counts_per_degree
        if degrees > degrees_in_coordinate
          degrees = degrees - (2 * degrees_in_coordinate)
        end
        degrees
      end

      private

      attr_accessor :node

      def mask
        @mask ||= node.at_xpath('payload').text.hex
      end
    end
  end
end
