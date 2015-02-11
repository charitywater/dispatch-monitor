require 'spec_helper'

module RemoteMonitoring
  module PostProcessor
    describe SurveyTicketCreator do
      let(:ticket_creator) { SurveyTicketCreator.new }

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
            survey_response: survey_response,
          )
        end

        let!(:submitted_at) { 7.days.ago }
        let!(:project) { create(:project) }
        let!(:survey_response) do
          create(
            :survey_response,
            :source_observation_v02,
            id: 3,
            submitted_at: submitted_at,
            project: project,
          )
        end
        let(:ticket_has_due_date?) { true }

        context 'new ticket should be created' do
          let(:create_new_ticket?) { true }

          context 'existing ticket' do
            let!(:started_at) { 3.months.ago }
            let!(:due_at) { 2.months.ago }
            let!(:existing_ticket) do
              create(
                :ticket,
                :complete,
                survey_response: survey_response,
                started_at: started_at,
                due_at: due_at,
              )
            end

            it 'does not update the ticket' do
              expect { ticket_creator.process(policy) }.not_to change { Ticket.count }
              expect { ticket_creator.process(policy) }.not_to change { existing_ticket.reload.status }

              ticket_creator.process(policy)
              existing_ticket.reload
              expect(existing_ticket.started_at).to be_within(0.000_001).of(started_at)
              expect(existing_ticket.due_at).to be_within(0.000_001).of(due_at)
            end
          end

          context 'new ticket' do
            it 'creates a new ticket' do
              expect(Ticket.count).to eq 0

              ticket_creator.process(policy)
              ticket = Ticket.last

              expect(Ticket.count).to eq 1
              expect(ticket).to be_in_progress
              expect(ticket.started_at).to be_within(0.000_001).of(submitted_at)
              expect(ticket.survey_response).to eq survey_response
              expect(ticket.project).to eq project
            end

            context 'ticket has due date' do
              let(:ticket_has_due_date?) { true }

              specify do
                ticket_creator.process(policy)

                expect(Ticket.last.due_at).to be_within(0.000_001).of(submitted_at + 30.days)
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
end
