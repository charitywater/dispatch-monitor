require 'spec_helper'

module Gps
  describe ReceiveController do
    describe '#create' do
      let(:message_id) { '930d23f0567710058db5ffb99d435d16' }
      let(:stu_xml_request) do
        <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
        <stuMessages xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://cody.glpconnect.com/XSD/StuMessage_Rev1_0_1.xsd" timeStamp="03/06/2014 18:14:44 GMT" messageID="#{message_id}">
        </stuMessages>
        XML
      end

      let(:prv_xml_request) do
        <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
        <prvmsgs xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://cody.glpconnect.com/XSD/ProvisionMessage_Rev1_0.xsd" timeStamp="04/09/2014 19:36:41 GMT" prvMessageID="#{message_id}">
        </prvmsgs>
        XML
      end

      let(:importer) { double(:importer, import: true) }

      before do
        allow(Rails.logger).to receive(:info)
        allow(RemoteMonitoring::JobQueue).to receive(:enqueue)
      end

      context 'received stuMessage' do
        it 'returns 200' do
          post :create, stu_xml_request, format: :xml

          expect(response).to be_success
        end

        it 'returns a stuMessage' do
          post :create, stu_xml_request, format: :xml

          assert_template :stu
        end

        it 'assigns the message id' do
          post :create, stu_xml_request, format: :xml

          expect(assigns(:message_id)).to eq(message_id)
        end

        it 'assigns the delivered_at' do
          post :create, stu_xml_request, format: :xml

          expect(assigns(:delivered_at)).to be
        end

        it 'enqueues an Import::GpsDataJob' do
          post :create, stu_xml_request, format: :xml

          expect(RemoteMonitoring::JobQueue).to have_received(:enqueue)
            .with(Import::GpsDataJob, stu_xml_request)
        end
      end

      context 'received prvMessage' do
        it 'returns 200' do
          post :create, prv_xml_request, format: :xml

          expect(response).to be_success
        end

        it 'returns a prvMessage' do
          post :create, prv_xml_request, format: :xml
          
          assert_template :prv
        end

        it 'assigns the message id' do
          post :create, prv_xml_request, format: :xml

          expect(assigns(:message_id)).to eq(message_id)
        end

        it 'assigns the delivered_at' do
          post :create, prv_xml_request, format: :xml

          expect(assigns(:delivered_at)).to be
        end

        it 'enqueues an Import::GpsDataJob' do
          post :create, prv_xml_request, format: :xml

          expect(RemoteMonitoring::JobQueue).to have_received(:enqueue)
            .with(Import::GpsDataJob, prv_xml_request)
        end
      end
    end
  end
end
