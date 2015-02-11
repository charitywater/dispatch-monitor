require 'spec_helper'

describe ManuallyCreatedTicket do
  let(:account) { create(:account, :admin) }
  let(:project) { create(:project, :flowing) }
  let(:project_status) { 'needs_visit' }
  let(:ticket) do
    ManuallyCreatedTicket.new(
      status: :in_progress,
      project: project,
      project_status: project_status,
      started_at: Time.zone.now + 1.day,
      manually_created_by: account,
    )
  end

  describe 'validations' do
    it 'requires a flowing/unknown project' do
      ticket.started_at = Time.zone.now + 1.day

      valid_statuses = %i(unknown flowing)

      valid_statuses.each do |status|
        project.status = status
        expect(ticket).to be_valid
      end

      Project.statuses.except(*valid_statuses).keys.each do |status|
        project.status = status
        expect(ticket).not_to be_valid
        expect(ticket.errors[:project]).to eq ['must be flowing or unknown']
      end
    end

    it 'requires a project status' do
      expect(ticket).to validate_presence_of(:project_status)
    end

    specify do
      expect(ticket).to validate_inclusion_of(:project_status)
        .in_array(%w(needs_maintenance needs_visit))
    end

    describe '#started_at' do
      before do
        Timecop.freeze DateTime.new(1500)
      end

      after do
        Timecop.return
      end

      it 'allows a started_at of now' do
        ticket.started_at = Time.zone.now.beginning_of_day

        expect(ticket).to be_valid
      end

      it 'allows a started_at of two years from now' do
        ticket.started_at = (Time.zone.now + 2.years).end_of_day

        expect(ticket).to be_valid
      end

      it 'allows a started_at within now and two years from now' do
        ticket.started_at = (Time.zone.now + 3.months)

        expect(ticket).to be_valid
      end

      it 'does not allow a started_at before now' do
        ticket.started_at = Time.zone.now.beginning_of_day - 1.second

        expect(ticket).not_to be_valid
        expect(ticket.errors[:started_at]).to eq ['cannot be in the past']
      end

      it 'does not allow a started_at after two years from now' do
        ticket.started_at = (Time.zone.now + 2.years).end_of_day + 1.second

        expect(ticket).not_to be_valid
        expect(ticket.errors[:started_at]).to eq ['must be before two years from now']
      end
    end

    describe '#due_at' do
      it 'allows a due_at of now' do
        ticket.due_at = Time.zone.now.beginning_of_day
        ticket.started_at = ticket.due_at

        expect(ticket).to be_valid
      end

      it 'allows a due_at of two years from now' do
        ticket.due_at = (Time.zone.now + 2.years).end_of_day
        ticket.started_at = ticket.due_at

        expect(ticket).to be_valid
      end

      it 'allows a due_at within now and two years from now' do
        ticket.due_at = (Time.zone.now + 3.months)
        ticket.started_at = ticket.due_at

        expect(ticket).to be_valid
      end

      it 'does not allow a due_at before now' do
        ticket.due_at = Time.zone.now.beginning_of_day - 1.second
        ticket.started_at = ticket.due_at

        expect(ticket).not_to be_valid
        expect(ticket.errors[:due_at]).to eq ['cannot be in the past']
      end

      it 'does not allow a due_at after two years from now' do
        ticket.due_at = (Time.zone.now + 2.years).end_of_day + 1.second
        ticket.started_at = ticket.due_at

        expect(ticket).not_to be_valid
        expect(ticket.errors[:due_at]).to eq ['must be before two years from now']
      end
    end
  end

  describe '#save' do
    it 'updates the Project’s status' do
      expect(project).to be_flowing

      ticket.save

      expect(project.reload).to be_needs_visit
    end

    it 'creates a new "manual" activity with the new project status' do
      expect(project.activities.status_changed_to_needs_visit.manually_created.count).to eq 0

      ticket.save

      expect(project.activities.status_changed_to_needs_visit.manually_created.count).to eq 1
    end

    describe 'default due_at' do
      before do
        ticket.started_at = Time.zone.now
      end

      context 'when the due_at is blank' do
        before do
          ticket.due_at = nil
        end

        context 'and project_status is needs_maintenance' do
          before do
            ticket.project_status = 'needs_maintenance'
          end

          it 'sets the due_at to 30 days after started_at' do
            ticket.save

            expect(ticket.reload.due_at).to be_within(0.000_001).of(ticket.started_at + 30.days)
          end
        end

        context 'and project_status is needs_visit' do
          before do
            ticket.project_status = 'needs_visit'
          end

          it 'leaves the due_at blank' do
            ticket.save

            expect(ticket.reload.due_at).to be_nil
          end
        end
      end

      context 'when the due_at is present' do
        let!(:due_at) { Time.zone.now + 2.days }
        before do
          ticket.project_status = 'needs_maintenance'
          ticket.due_at = due_at
        end

        it 'is not overridden' do
          ticket.save

          expect(ticket.reload.due_at).to be_within(0.000_001).of(due_at)
        end
      end
    end
  end
end
