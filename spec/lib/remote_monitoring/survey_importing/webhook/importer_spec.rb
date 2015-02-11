require 'spec_helper'

module RemoteMonitoring
  module SurveyImporting
    module Webhook
      describe Importer do
        let(:importer) { Webhook::Importer.new(survey_importer: survey_importer) }
        let(:survey_importer) { double(:survey_importer, import: nil) }

        describe '#import' do
          let(:params) { { 'survey_type' => 'maintenance_report_v02' } }
          let(:parsed_response) { double(:parsed_response) }

          before do
            allow(FluidSurveys::Structure::MaintenanceReportV02).to receive(:new).with(params) { parsed_response }
          end

          it 'calls the survey importer with the response' do
            importer.import(params)

            expect(survey_importer).to have_received(:import).with(parsed_response)
          end
        end
      end
    end
  end
end
