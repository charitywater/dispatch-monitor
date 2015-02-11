require 'spec_helper'

describe TicketPresenter do
  include Rails.application.routes.url_helpers

  let(:project) { build(:project, latitude: 1.9999999999, longitude: -50.54273859) }
  let(:survey_response) { build(:survey_response, project: project) }
  let(:ticket) { build(:ticket, :in_progress, id: 5, survey_response: survey_response, project: project) }
  let(:presenter) { TicketPresenter.new(ticket) }

  describe '#due_at' do
    context 'due_at is present' do
      before do
        ticket.due_at = DateTime.new(2012, 3, 4, 5, 6, 7)
      end

      it 'formats the date' do
        expect(presenter.due_at).to eq('2012-03-04')
      end
    end

    context 'due_at is blank' do
      before do
        ticket.due_at = nil
      end

      it 'returns nil' do
        expect(presenter.due_at).to be_nil
      end
    end
  end

  describe '#started_at' do
    before do
      ticket.started_at = DateTime.new(2012, 3, 4, 5, 6, 7)
    end

    it 'formats the date' do
      expect(presenter.started_at).to eq('2012-03-04')
    end
  end

  describe '#completed_at' do
    context 'when present' do
      before do
        ticket.completed_at = DateTime.new(2012, 3, 4, 5, 6, 7)
      end

      it 'formats the date' do
        expect(presenter.completed_at).to eq('2012-03-04')
      end
    end

    context 'when nil' do
      before do
        ticket.completed_at = nil
      end

      it 'returns nil' do
        expect(presenter.completed_at).to be_nil
      end
    end
  end

  describe '#status_tag' do
    before do
      ticket.due_at = 3.days.from_now
    end

    it 'returns the ticket’s status as a phrase' do
      expect(presenter.status_tag).to include 'In Progress'
    end
  end

  describe '#project_status_tag' do
    before do
      ticket.project.status = :flowing
      ticket.project.id = 1
    end

    it 'returns the project status as a link to the project' do
      expect(presenter.project_status_tag).to include map_project_path(ticket.project)
      expect(presenter.project_status_tag).to include 'Flowing'
    end
  end

  describe '#as_json' do
    before do
      ticket.due_at = DateTime.new(9000, 1, 4, 5, 6, 7)
      ticket.started_at = DateTime.new(2013, 4, 5, 6, 7, 8)
      ticket.completed_at = DateTime.new(2013, 5, 6, 7, 8, 9)
      ticket.manually_created_by = Account.new(email: 'hi@example.com')
      ticket.manually_completed_by = Account.new(email: 'bye@example.com')
      ticket.manually_completed_by = Account.new(email: 'bye@example.com')
      ticket.weekly_log = WeeklyLog.new(id: 15)
    end

    it 'returns the id, status, due_at, and completed_at' do
      expect(presenter.as_json).to eq(
        id: 5,
        status: 'in_progress',
        started_at: '2013-04-05',
        due_at: '9000-01-04',
        completed_at: '2013-05-06',
        manually_created_by: {
          email: 'hi@example.com'
        },
        manually_completed_by: {
          email: 'bye@example.com'
        },
        generated_by_sensor: 15,
      )
    end
  end

  describe '#gps' do
    it 'rounds to the sixth decimal place' do
      expect(presenter.gps).to eq '2.000000, -50.542739'
    end
  end

  describe '#country' do
    before do
      project.country.name = 'Fancy Australia'
    end

    specify do
      expect(presenter.country).to eq 'Fancy Australia'
    end
  end

  describe '#flowing_water_answer' do
    before do
      allow(survey_response).to receive(:flowing_water_answer) { flowing_water_answer }
    end

    context 'there is an answer' do
      let(:flowing_water_answer) { 'Yes' }

      specify do
        expect(presenter.flowing_water_answer).to include 'Yes'
      end
    end

    context 'there is no answer' do
      let(:flowing_water_answer) { nil }

      it 'returns a default string' do
        expect(presenter.flowing_water_answer).to include 'N/A'
      end
    end
  end

  describe '#consumable_water_answer' do
    before do
      allow(survey_response).to receive(:consumable_water_answer) { consumable_water_answer }
    end

    context 'there is an answer' do
      let(:consumable_water_answer) { 'Yes' }

      specify do
        expect(presenter.consumable_water_answer).to include 'Yes'
      end
    end

    context 'there is no answer' do
      let(:consumable_water_answer) { nil }

      it 'returns a default string' do
        expect(presenter.consumable_water_answer).to include 'N/A'
      end
    end
  end

  describe '#maintenance_visit_answer' do
    before do
      allow(survey_response).to receive(:maintenance_visit_answer) { maintenance_visit_answer }
    end

    context 'there is an answer' do
      let(:maintenance_visit_answer) { 'Yes' }

      specify do
        expect(presenter.maintenance_visit_answer).to include 'Yes'
      end
    end

    context 'there is no answer' do
      let(:maintenance_visit_answer) { nil }

      it 'returns a default string' do
        expect(presenter.maintenance_visit_answer).to include 'N/A'
      end
    end
  end

  describe '#notes' do
    before do
      allow(survey_response).to receive(:notes) { survey_response_notes }

      ticket.notes = notes
    end

    context 'there are notes in the ticket' do
      let(:notes) { 'Ticket notes' }
      let(:survey_response_notes) { 'Some notes' }

      specify do
        expect(presenter.notes).to eq 'Ticket notes'
      end
    end

    context 'there are notes in the survey but not in the ticket' do
      let(:survey_response_notes) { 'Some notes' }
      let(:notes) { '' }

      specify do
        expect(presenter.notes).to eq 'Some notes'
      end
    end

    context 'the notes are empty' do
      let(:notes) { '' }
      let(:survey_response_notes) { '' }

      it 'returns a default string' do
        expect(presenter.notes).to eq 'N/A'
      end
    end

    context 'there are no notes' do
      let(:notes) { nil }
      let(:survey_response_notes) { nil }

      it 'returns a default string' do
        expect(presenter.notes).to eq 'N/A'
      end
    end
  end

  describe '#contact_name' do
    before do
      ticket.project.contact_name = 'Fancy Contact'
    end

    specify do
      expect(presenter.contact_name).to eq 'Fancy Contact'
    end
  end

  describe '#contact_email' do
    before do
      ticket.project.contact_email = 'fancy.contact@example.com'
    end

    specify do
      expect(presenter.contact_email).to eq 'fancy.contact@example.com'
    end
  end

  describe '#contact_phone_numbers' do
    before do
      ticket.project.contact_phone_numbers = ['+1 800 800 8000', '0033 123 456']
    end

    specify do
      expect(presenter.contact_phone_numbers).to eq ['+1 800 800 8000', '0033 123 456']
    end
  end
end
