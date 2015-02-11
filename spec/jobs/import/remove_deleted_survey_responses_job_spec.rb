require 'spec_helper'

module Import
  describe RemoveDeletedSurveyResponsesJob do
    describe '.queue' do
      specify do
        expect(RemoveDeletedSurveyResponsesJob.queue).to eq :import
      end
    end

    describe '.perform' do
      let(:remover) { double(:remover, remove_deleted: nil) }

      before do
        allow(RemoteMonitoring::SurveyImporting::Remover).to receive(:new) { remover }
      end

      it 'delegates to the remover' do
        RemoveDeletedSurveyResponsesJob.perform
        expect(remover).to have_received(:remove_deleted)
      end
    end
  end
end
