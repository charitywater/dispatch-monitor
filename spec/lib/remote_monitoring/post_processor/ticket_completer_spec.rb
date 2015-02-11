require 'spec_helper'

module RemoteMonitoring
    module PostProcessor
      describe TicketCompleter do
        let(:policy) do
          double(
            :policy,
            complete_previous_tickets?: complete_previous_tickets?,
            project: project,
            happened_at: now,
          )
        end

        let(:ticket_completer) { TicketCompleter.new }
        let(:now) { DateTime.new(2014) }

        before do
          Timecop.freeze now
        end

        after do
          Timecop.return
        end

        describe '#process' do
          let!(:project) { create(:project) }

          context 'previous tickets should be completed' do
            let(:complete_previous_tickets?) { true }

            context 'in-progress ticket created before the maintenance report' do
              let!(:ticket) do
                create(
                  :ticket,
                  :in_progress,
                  created_at: 20.days.ago,
                  project: project
                )
              end

              it 'completes the tickets' do
                expect(Ticket.count).to eq 1

                ticket_completer.process(policy)

                ticket.reload
                expect(ticket).to be_complete
                expect(ticket.completed_at).to eq now
              end
            end

            context 'a complete ticket created before the maintenance report' do
              let!(:ticket) do
                create(
                  :ticket,
                  :complete,
                  started_at: 20.years.ago,
                  completed_at: 18.years.ago,
                  project: project
                )
              end

              it 'does nothing' do
                ticket_completer.process(policy)

                ticket.reload
                expect(ticket).to be_complete
                expect(ticket.completed_at).to eq 18.years.ago
              end
            end

            context 'in-progress ticket created within the 30-minute overlap' do
              let!(:ticket) do
                create(
                  :ticket,
                  :in_progress,
                  started_at: 29.minutes.from_now,
                  project: project
                )
              end

              it 'completes the ticket' do
                ticket_completer.process(policy)

                ticket.reload
                expect(ticket).to be_complete
                expect(ticket.completed_at).to eq now
              end
            end

            context 'an in-progress ticket created after the 30-minute overlap' do
              let!(:ticket) do
                create(
                  :ticket,
                  :in_progress,
                  started_at: 2.days.from_now,
                  project: project
                )
              end

              it 'does nothing' do
                ticket_completer.process(policy)

                ticket.reload
                expect(ticket).to be_in_progress
                expect(ticket.completed_at).to be_nil
              end
            end
          end

          context 'previous tickets should not be completed' do
            let(:complete_previous_tickets?) { false }
            let!(:ticket) do
              create(
                :ticket,
                :in_progress,
                created_at: 20.days.ago,
                project: project
              )
            end

            it 'does nothing' do
              ticket_completer.process(policy)

              ticket.reload
              expect(ticket).to be_in_progress
              expect(ticket.completed_at).to be_nil
            end
          end
        end
      end
    end
  end
