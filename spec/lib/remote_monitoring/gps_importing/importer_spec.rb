require 'spec_helper'

module RemoteMonitoring
  module GpsImporting
    describe Importer do
      let(:wazi_client) { double(:wazi_client, send_gps: true) }
      let(:importer) { RemoteMonitoring::GpsImporting::Importer.new(wazi_client: wazi_client) }

      let(:esn) { '0-1247106' }
      let(:unixtime) { '1402502351' }
      let(:payload_hex) { '0x0014266C1C21AF0A50' }
      let(:message_id) { '930d23f0567710058db5ffb99d435d16' }
      let(:stu_xml) do
        <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
        <stuMessages xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://cody.glpconnect.com/XSD/StuMessage_Rev1_0_1.xsd" timeStamp="03/06/2014 18:14:44 GMT" messageID="#{message_id}">
          <stuMessage>
            <esn>#{esn}</esn>
            <unixTime>#{unixtime}</unixTime>
            <gps>N</gps>
            <payload length="9" source="pc" encoding="hex">#{payload_hex}</payload>
          </stuMessage>
        </stuMessages>
        XML
      end

      let(:prv_xml) do
        <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
        <prvmsgs xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://cody.glpconnect.com/XSD/ProvisionMessage_Rev1_0.xsd" timeStamp="04/09/2014 19:36:41 GMT" prvMessageID="#{message_id}">
        </prvmsgs>
        XML
      end

      context 'receive a stuMessage' do
        describe '#import' do
          it 'stores the message' do
            expect { importer.import(stu_xml) }.to change(GpsMessage, :count).by(1)
          end

          it 'assigns the correct vehicle' do
            vehicle = create(:vehicle, esn: esn)
            importer.import(stu_xml)

            expect(vehicle.gps_messages.count).to eq 1
          end

          it 'sends the valid gps messages to wazi' do
            importer.import(stu_xml)

            expect(wazi_client).to have_received(:send_gps).once
          end
        end
      end

      context 'receive a prvMessage' do
        describe '#import' do
          it 'does not store the message' do
            expect { importer.import(prv_xml) }.to_not change(GpsMessage, :count)
          end

          it 'does not process provisioning messages' do
            importer.import(prv_xml)

            expect(wazi_client).to_not have_received(:send_gps)
          end
        end
      end
    end
  end
end
