require 'spec_helper'

describe ManuallyCompletedTicket do
  let(:project) { create(:project, :needs_maintenance) }
  let(:original_ticket) do
    create(
      :ticket,
      original_status,
      started_at: 3.days.ago,
      project: project,
    )
  end
  let(:original_status) { :in_progress }

  let(:account) { create(:account, :admin) }
  let(:ticket) { ManuallyCompletedTicket.find(original_ticket.id) }

  describe 'validations' do
    it 'requires a needs_maintenance/needs_visit project' do
      ticket.project_status = 'flowing'
      ticket.started_at = Time.zone.now + 1.day
      valid_statuses = %i(needs_maintenance needs_visit)

      valid_statuses.each do |status|
        ticket.project.status = status
        expect(ticket).to be_valid
      end

      Project.statuses.except(*valid_statuses).keys.each do |status|
        ticket.project.status = status
        expect(ticket).not_to be_valid
        expect(ticket.errors[:project]).to eq ['must be needs maintenance or needs visit']
      end
    end

    it 'requires a project status' do
      expect(ticket).to validate_presence_of(:project_status)
    end

    specify do
      expect(ticket).to validate_inclusion_of(:project_status)
        .in_array(%w(flowing inactive))
    end
  end

  describe '#update' do
    context 'ticket can be completed' do
      let(:original_status) { :in_progress }

      before do
        Timecop.freeze DateTime.new(2000)

        ticket.update(
          manually_completed_by: account,
          project_status: 'flowing',
        )
      end

      after do
        Timecop.return
      end

      it 'sets the status to Complete' do
        expect(ticket.reload).to be_complete
      end

      it 'sets the manually_completed_by' do
        expect(ticket.reload.manually_completed_by).to eq account
      end

      it 'sets the completed_at' do
        expect(ticket.reload.completed_at).to eq DateTime.new(2000)
      end

      it 'sets the project’s status to Flowing' do
        expect(ticket.project.reload).to be_flowing
      end

      it 'creates the ProjectStatusChanged activity' do
        activity = Activity.last

        expect(activity).to be_status_changed
        expect(activity.data['status']).to eq Project.statuses[:flowing]
        expect(activity.manually_created_by).to eq account
      end
    end

    context 'ticket cannot be completed' do
      let(:original_status) { :complete }

      before do
        ticket.update(manually_completed_by: account)
      end

      it 'leaves the status as Complete' do
        expect(ticket.reload).to be_complete
      end

      it 'does not set the manually_completed_by' do
        expect(ticket.reload.manually_completed_by).to be_nil
      end

      it 'does not set the completed_at' do
        expect(ticket.reload.completed_at).to be_nil
      end

      it 'does not set the project’s status to Flowing' do
        expect(ticket.project.reload).not_to be_flowing
      end

      it 'does not create the ProjectStatusChanged activity' do
        expect(Activity.count).to eq 0
      end
    end
  end
end
