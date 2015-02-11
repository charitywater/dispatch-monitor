require 'spec_helper'

module RemoteMonitoring
  describe JobQueue do
    let(:job) { double(:job) }
    let(:argument) { double(:argument) }

    describe '.enqueue' do
      before do
        allow(Resque).to receive(:enqueue)
      end

      specify do
        JobQueue.enqueue(job)

        expect(Resque).to have_received(:enqueue).with(job)
      end

      specify do
        JobQueue.enqueue(job, argument)

        expect(Resque).to have_received(:enqueue).with(job, argument)
      end

      specify do
        expect { JobQueue.enqueue }.to raise_error(ArgumentError)
      end
    end

    context '.enqueue_in' do
      before do
        allow(Resque).to receive(:enqueue_in)
      end

      specify do
        JobQueue.enqueue_in(10, job)

        expect(Resque).to have_received(:enqueue_in).with(10, job)
      end

      specify do
        JobQueue.enqueue_in(20, job, argument)

        expect(Resque).to have_received(:enqueue_in).with(20, job, argument)
      end

      specify do
        expect { JobQueue.enqueue_in(job) }.to raise_error(ArgumentError)
      end
    end
  end
end
