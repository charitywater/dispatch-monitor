require 'spec_helper'

module RemoteMonitoring
  module GpsImporting
    describe PayloadFormatter do
      let(:payload) do
        double(
          :payload,
          message_time_gmt: DateTime.new(2014, 06, 11, 15, 59, 11),
          esn: 'esn',
          latitude: -0.12345611111,
          longitude: -9.9999999999,
          gps_quality: 'High',
          message_type_or_subtype: 'Location',
        )
      end
      let(:formatter) { PayloadFormatter.new(payload) }

      describe '#to_s' do
        it 'converts the Payload to the string that Wazi expects' do
          result = [
            '2014/06/11 15:59:11',
            'esn',
            'xx',
            'xx',
            'xx',
            'esn',
            'xx',
            '2014/06/11 15:59:11',
            'Location',
            'xx',
            'xx',
            'xx',
            'xx',
            '-10.000000',
            '-0.123456',
            'xx',
            'xx',
            'xx',
            'xx',
            'xx',
            'High',
          ].join("\t")

          expect(formatter.to_s).to eq result
        end
      end
    end
  end
end
