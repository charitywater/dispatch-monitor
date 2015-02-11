require 'spec_helper'

module RemoteMonitoring
  describe ErrorNotifier do
    let(:e) { double(:e) }

    before do
      allow(Raven).to receive(:capture_exception)
    end

    specify do
      ErrorNotifier.notify(e)

      expect(Raven).to have_received(:capture_exception).with(e)
    end
  end
end
