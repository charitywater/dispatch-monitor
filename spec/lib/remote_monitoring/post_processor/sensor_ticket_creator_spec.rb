require 'spec_helper'

module RemoteMonitoring
  module PostProcessor
    describe SensorTicketCreator do
      let(:ticket_creator) { SensorTicketCreator.new }

      before do
        Timecop.freeze
      end

      after do
        Timecop.return
      end

      describe '#process' do
        let(:policy) do
          double(
            :policy,
            create_new_ticket?: create_new_ticket?,
            ticket_has_due_date?: ticket_has_due_date?,
            flowing_water_answer: 'No',
            maintenance_visit_answer: 'Yes',
            weekly_log: weekly_log,
            happened_at: happened_at,
          )
        end

        let!(:happened_at) { 7.days.ago }
        let!(:project) { create(:project) }
        let!(:sensor) { create(:sensor, project: project) }
        let!(:weekly_log) { create(:weekly_log, id: 3, sensor: sensor) }
        let(:ticket_has_due_date?) { true }

        context 'new ticket should be created' do
          let(:create_new_ticket?) { true }

          it 'creates a new ticket' do
            expect(Ticket.count).to eq 0

            ticket_creator.process(policy)
            ticket = Ticket.last

            expect(Ticket.count).to eq 1
            expect(ticket).to be_in_progress
            expect(ticket.started_at).to be_within(0.000_001).of(happened_at)
            expect(ticket.weekly_log).to eq weekly_log
            expect(ticket.project).to eq project
            expect(ticket.flowing_water_answer).to eq 'No'
            expect(ticket.maintenance_visit_answer).to eq 'Yes'
          end

          context 'ticket has due date' do
            let(:ticket_has_due_date?) { true }

            specify do
              ticket_creator.process(policy)

              expect(Ticket.last.due_at).to be_within(0.000_001).of(happened_at + 30.days)
            end
          end

          context 'ticket does not have due date' do
            let(:ticket_has_due_date?) { false }

            specify do
              ticket_creator.process(policy)

              expect(Ticket.last.due_at).to be_nil
            end
          end
        end

        context 'new ticket should not be created' do
          let(:create_new_ticket?) { false }

          it 'does nothing' do
            ticket_creator.process(policy)

            expect(Ticket.count).to eq 0
          end
        end
      end
    end
  end
end
