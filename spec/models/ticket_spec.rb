require 'spec_helper'

describe Ticket do
  let(:ticket) { Ticket.new }

  describe 'validations' do
    specify do
      expect(ticket).to validate_presence_of(:started_at)
    end

    specify do
      expect(ticket).to validate_presence_of(:status)
    end

    specify do
      expect(ticket).to validate_presence_of(:project_id)
    end

    specify do
      expect(ticket).not_to validate_presence_of(:survey_response_id)
    end

    describe '#due_at' do
      let(:ticket) { create(:ticket, :in_progress) }

      it 'allows started_at < due_at' do
        ticket.started_at = 4.days.ago
        ticket.due_at = 2.days.ago

        expect(ticket).to be_valid
      end

      it 'allows started_at == due_at' do
        ticket.started_at = 2.days.ago
        ticket.due_at = ticket.started_at

        expect(ticket).to be_valid
      end

      it 'does not allow due_at < started_at' do
        ticket.due_at = 4.days.ago
        ticket.started_at = 2.days.ago

        expect(ticket).not_to be_valid
        expect(ticket.errors[:due_at]).not_to be_empty
      end

      it 'allows due_at to be nil' do
        ticket.started_at = 3.days.ago
        ticket.due_at = nil

        expect(ticket).to be_valid
      end
    end
  end

  describe 'associations' do
    specify do
      expect(ticket).to belong_to(:project)
    end

    specify do
      expect(ticket).to belong_to(:survey_response)
    end

    specify do
      expect(ticket).to belong_to(:weekly_log)
    end

    specify do
      expect(ticket).to have_one(:program).through(:project)
    end

    specify do
      expect(ticket).to belong_to(:manually_created_by).class_name('Account')
    end

    specify do
      expect(ticket).to belong_to(:manually_completed_by).class_name('Account')
    end
  end

  describe '.statuses' do
    it 'includes the overdue status' do
      expect(Ticket.statuses.keys).to eq %w(in_progress complete overdue)
      expect(Ticket.statuses.values).to eq [0, 1, 2]
    end
  end

  describe '.non_deleted' do
    let!(:ticket) { create(:ticket, deleted_at: nil) }
    let!(:deleted) { create(:ticket, deleted_at: Time.zone.now) }

    it 'returns only the non-deleted Tickets' do
      expect(Ticket.non_deleted).to eq [ticket]
    end
  end

  describe '.deleted' do
    let!(:ticket) { create(:ticket, deleted_at: nil) }
    let!(:deleted) { create(:ticket, deleted_at: Time.zone.now) }

    it 'returns only the deleted Tickets' do
      expect(Ticket.deleted).to eq [deleted]
    end
  end

  describe '.in_progress' do
    before do
      Timecop.travel DateTime.new(2014, 01, 01, 12)
    end

    after do
      Timecop.return
    end

    it 'returns only the in-progress Tickets' do
      in_progress = create(:ticket, :in_progress)
      no_due_at = create(:ticket, :in_progress, due_at: nil)
      due_today = create(:ticket, :due_today)
      create(:ticket, :complete)
      create(:ticket, :overdue)

      expect(Ticket.in_progress).to match_array [in_progress, due_today, no_due_at]
    end
  end

  describe '.overdue' do
    before do
      Timecop.travel DateTime.new(2014, 01, 01, 12)
    end

    after do
      Timecop.return
    end

    it 'returns only the overdue Tickets' do
      create(:ticket, :in_progress)
      create(:ticket, :due_today)
      create(:ticket, :complete)
      overdue = create(:ticket, :overdue)

      expect(Ticket.overdue).to eq [overdue]
    end
  end

  describe '.incomplete' do
    before do
      Timecop.travel DateTime.new(2014, 01, 01, 12)
    end

    after do
      Timecop.return
    end

    it 'returns only Tickets that are not complete' do
      create(:ticket, :complete)
      in_progress = create(:ticket, :in_progress)
      overdue = create(:ticket, :overdue)

      expect(Ticket.incomplete).to match_array [in_progress, overdue]
    end
  end

  describe '.due_soon' do
    before do
      Timecop.travel DateTime.new(2014, 01, 07, 17)
    end

    after do
      Timecop.return
    end

    it 'returns only the Tickets due within 7 days' do
      expected = [
        create(:ticket, :in_progress, due_at: 7.days.from_now + 1.hour),
        create(:ticket, :in_progress, due_at: 7.days.from_now - 1.hour),
        create(:ticket, :in_progress, due_at: 6.days.from_now),
        create(:ticket, :due_today)
      ]
      create(:ticket, :in_progress, due_at: 8.days.from_now)
      create(:ticket, :complete)
      create(:ticket, :overdue)

      expect(Ticket.due_soon).to match_array expected
    end
  end

  describe '#soft_delete' do
    let!(:ticket) { create(:ticket) }

    it 'sets the deleted_at field' do
      expect(ticket.reload.deleted_at).not_to be

      ticket.soft_delete

      expect(ticket.reload.deleted_at).to be
    end
  end

  describe '#status' do
    before do
      Timecop.travel DateTime.new(2012, 1, 2, 15, 0, 0)
    end

    after do
      Timecop.return
    end

    context 'when overdue' do
      before do
        ticket.due_at = 1.day.ago
      end

      it 'returns "overdue" for in progress tickets' do
        ticket.status = :in_progress
        expect(ticket.status).to eq 'overdue'
        expect(ticket).to be_overdue
      end

      it 'returns "complete" for complete tickets' do
        ticket.status = :complete
        expect(ticket.status).to eq 'complete'
        expect(ticket).not_to be_overdue
      end
    end

    context 'when not overdue' do
      before do
        ticket.due_at = 3.days.from_now
      end

      it 'returns "in progress" for in progress tickets' do
        ticket.status = :in_progress
        expect(ticket.status).to eq 'in_progress'
        expect(ticket).not_to be_overdue
      end

      it 'returns "complete" for complete tickets' do
        ticket.status = :complete
        expect(ticket.status).to eq 'complete'
        expect(ticket).not_to be_overdue
      end
    end

    context 'when due today' do
      before do
        ticket.due_at = DateTime.new(2012, 1, 2, 0, 0, 0, '+0')
      end

      it 'returns "in progress" for in progress tickets' do
        ticket.status = :in_progress
        expect(ticket.status).to eq 'in_progress'
        expect(ticket).not_to be_overdue
      end

      it 'returns "complete" for complete tickets' do
        ticket.status = :complete
        expect(ticket.status).to eq 'complete'
        expect(ticket).not_to be_overdue
      end
    end

    context 'when in progress without a due date' do
      before do
        ticket.due_at = nil
      end

      it 'returns "in progress" for in progress tickets' do
        ticket.status = :in_progress
        expect(ticket.status).to eq 'in_progress'
        expect(ticket).not_to be_overdue
      end
    end
  end

  describe '#community_name' do
    let(:project) { build(:project, community_name: 'Fancy Community') }

    before do
      ticket.project = project
    end

    it 'returns the project’s community name' do
      expect(ticket.community_name).to eq 'Fancy Community'
    end
  end

  describe '#deployment_code' do
    let(:project) { build(:project, deployment_code: 'AA.AAA.Q1.11.111.111') }

    before do
      ticket.project = project
    end

    it 'returns the project’s deployment code' do
      expect(ticket.deployment_code).to eq 'AA.AAA.Q1.11.111.111'
    end
  end
end
