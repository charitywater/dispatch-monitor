require 'spec_helper'

module RemoteMonitoring
  module GpsImporting
    describe Payload do
      let(:payload) { RemoteMonitoring::GpsImporting::Payload.new(xml) }
      let(:xml) do
        Nokogiri::XML(<<-XML).root
        <stuMessage>
          <esn>#{esn}</esn>
          <unixTime>1402502351</unixTime>
          <gps>N</gps>
          <payload length="9" source="pc" encoding="hex">#{payload_hex}</payload>
        </stuMessage>
        XML
      end
      let(:esn) { '0-1227749' }
      let(:payload_hex) { '0x0014266C1C21AF0A50' }

      describe '#message_time_gmt' do
        let(:date) { DateTime.new(2014, 6, 11, 15, 59, 11) }
        specify do
          expect(payload.message_time_gmt).to eq date
        end
      end

      describe '#esn' do
        specify do
          expect(payload.esn).to eq '1227749'
        end
      end

      describe '#message_type_or_subtype' do
        context 'Subtype is Location' do
          let(:payload_hex) { '0xFCFFFFFFFFFFFF0FFF' }

          specify do
            expect(payload.message_type_or_subtype).to eq 'Location'
          end
        end

        context 'Type is not Type 0 Standard Message' do
          let(:payload_hex) { '0x030000000000000000' }

          specify do
            expect(payload.message_type_or_subtype).to eq 'Not Type 0 Standard Message'
          end
        end

        context 'Subtype is not Location' do
          let(:payload_hex) { '0x00000000000000F000' }

          specify do
            expect(payload.message_type_or_subtype).to eq 'Not Location Subtype'
          end
        end
      end

      describe '#calc_latitude' do
        context 'from a positive signed binary number' do
          let(:counts) { 0x2b5372 }

          specify do
            expect(payload.counts_to_degrees(counts, :latitude)).to be_within(0.0000214).of(30.463564)
          end
        end
      end

      describe '#calc_longitude' do
        context 'from a negative signed binary number' do
          let(:counts) { 0xbff12f }

          specify do
            expect(payload.counts_to_degrees(counts, :longitude)).to be_within(0.0000430).of(-90.081388)
          end
        end
      end

      describe '#latitude' do
        context 'from a positive signed binary number' do
          let(:payload_hex) { '0x2b5372bff12f0a02' }

          specify do
            expect(payload.latitude).to be_within(0.0000214).of(30.463564)
          end
        end
      end

      describe '#longitude' do
        context 'from a negative signed binary number' do
          let(:payload_hex) { '0x2b5372bff12f0a02' }

          specify do
            expect(payload.longitude).to be_within(0.0000430).of(-90.081388)
          end
        end
      end

      describe '#gps_quality' do
        context 'high confidence' do
          let(:payload_hex) { '0xFFFF7F' }

          specify do
            expect(payload.gps_quality).to eq 'High'
          end
        end

        context 'low confidence' do
          let(:payload_hex) { '0x80' }

          specify do
            expect(payload.gps_quality).to eq 'Reduced'
          end
        end
      end

      describe '#valid?' do
        ['0-1227749', '0-1227980'].each do |esn|
          context "when esn is #{esn}" do
            let(:esn) { esn }

            specify do
              expect(payload).to be_valid
            end
          end
        end

        context 'when esn is invalid' do
          let(:esn) { 'invalid esn' }

          specify do
            expect(payload).to be_invalid
          end
        end
      end
    end
  end
end
