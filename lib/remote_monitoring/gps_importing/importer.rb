module RemoteMonitoring
  module GpsImporting
    class Importer
      def initialize(wazi_client: Wazi::Client.new)
        @wazi_client = wazi_client
      end

      def import(xml)
        parsed_xml = Nokogiri::XML(xml)

        unless parsed_xml.element_children.first.name == "prvmsgs"
          parsed_xml.xpath('/stuMessages/stuMessage').each do |node|
            payload = Payload.new(node)
            if payload.valid?
              formatter = PayloadFormatter.new(payload)
              vehicle = Vehicle.find_by(esn: node.at_xpath('esn').text)
              GpsMessage.create(
                esn: formatter.esn,
                transmitted_at: formatter.message_time_gmt,
                payload: node.at_xpath('payload').text,
                message_type: formatter.message_type_or_subtype,
                latitude: formatter.latitude,
                longitude: formatter.longitude,
                confidence: formatter.gps_quality,
                vehicle: vehicle.nil? ? nil : vehicle
              )
              wazi_client.send_gps(formatter.to_s)
            end
          end
        end
      end

      private

      attr_reader :wazi_client
    end
  end
end
