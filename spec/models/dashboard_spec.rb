require 'spec_helper'

describe Dashboard do
  let(:account) { build(:account, :admin) }
  let(:filter_form) { double(:filter_form, current_account: account, program: program) }
  let(:dashboard) { Dashboard.new(filter_form) }
  let(:program_id) { double(:program_id) }
  let(:program) { double(:program, name: 'Program Name') }

  before do
    allow(Program).to receive(:find_by).with(id: program_id) { program }
  end

  describe '#total_project_count' do
    let(:total_projects) { double(:total_projects, count: 7) }

    before do
      allow(program).to receive(:projects) { total_projects }
    end

    it 'returns the total project count for the specified program' do
      expect(dashboard.total_project_count).to eq 7
      expect(dashboard.total_project_count).to eq 7

      expect(program).to have_received(:projects).once
    end
  end

  describe '#flowing_project_count' do
    let(:projects) { double(:projects, flowing: flowing_projects) }
    let(:flowing_projects) { double(:flowing_projects, count: 3) }

    before do
      allow(program).to receive(:projects) { projects }
    end

    it 'returns the flowing count for the specified program' do
      expect(dashboard.flowing_project_count).to eq 3
      expect(dashboard.flowing_project_count).to eq 3

      expect(program).to have_received(:projects).once
    end
  end

  describe '#needs_maintenance_project_count' do
    let(:projects) { double(:projects, needs_maintenance: needs_maintenance_projects) }
    let(:needs_maintenance_projects) { double(:needs_maintenance_projects, count: 3) }

    before do
      allow(program).to receive(:projects) { projects }
    end

    it 'returns the needs_maintenance count for the specified program' do
      expect(dashboard.needs_maintenance_project_count).to eq 3
      expect(dashboard.needs_maintenance_project_count).to eq 3

      expect(program).to have_received(:projects).once
    end
  end

  describe '#needs_visit_project_count' do
    let(:projects) { double(:projects, needs_visit: needs_visit_projects) }
    let(:needs_visit_projects) { double(:needs_visit_projects, count: 7) }

    before do
      allow(program).to receive(:projects) { projects }
    end

    it 'returns the needs_visit count for the specified program' do
      expect(dashboard.needs_visit_project_count).to eq 7
      expect(dashboard.needs_visit_project_count).to eq 7

      expect(program).to have_received(:projects).once
    end
  end

  describe '#inactive_project_count' do
    let(:projects) { double(:projects, inactive: inactive_projects) }
    let(:inactive_projects) { double(:inactive_projects, count: 3) }

    before do
      allow(program).to receive(:projects) { projects }
    end

    it 'returns the inactive count for the specified program' do
      expect(dashboard.inactive_project_count).to eq 3
      expect(dashboard.inactive_project_count).to eq 3

      expect(program).to have_received(:projects).once
    end
  end

  describe '#unknown_project_count' do
    let(:projects) { double(:projects, unknown: unknown_projects) }
    let(:unknown_projects) { double(:unknown_projects, count: 22) }

    before do
      allow(program).to receive(:projects) { projects }
    end

    it 'returns the needs_maintenance count for the specified program' do
      expect(dashboard.unknown_project_count).to eq 22
      expect(dashboard.unknown_project_count).to eq 22

      expect(program).to have_received(:projects).once
    end
  end

  describe '#total_survey_response_count' do
    let(:survey_responses) { double(:survey_responses) }
    let(:recent_survey_responses) { double(:recent_survey_responses, count: 5) }
    let(:since) { double(:since) }

    before do
      allow(filter_form).to receive(:since) { since }
      allow(program).to receive(:survey_responses) { survey_responses }
      allow(survey_responses).to receive(:since).with(since) { recent_survey_responses }
    end

    it 'returns the total count for the specified program' do
      expect(dashboard.total_survey_response_count).to eq 5
      expect(dashboard.total_survey_response_count).to eq 5

      expect(program).to have_received(:survey_responses).once
    end
  end

  describe '#source_observation_survey_response_count' do
    let(:survey_responses) { double(:survey_responses) }
    let(:recent_survey_responses) { double(:recent_survey_responses) }
    let(:source_observations) { double(:source_observations, count: 3) }
    let(:since) { double(:since) }

    before do
      allow(program).to receive(:survey_responses) { survey_responses }
      allow(survey_responses).to receive(:since).with(since) { recent_survey_responses }
      allow(filter_form).to receive(:since) { since }
      allow(recent_survey_responses).to receive(:source_observation) { source_observations }
    end

    it 'returns the source_observation count for the specified program' do
      expect(dashboard.source_observation_survey_response_count).to eq 3
      expect(dashboard.source_observation_survey_response_count).to eq 3

      expect(program).to have_received(:survey_responses).once
    end
  end

  describe '#maintenance_report_survey_response_count' do
    let(:survey_responses) { double(:survey_responses) }
    let(:recent_survey_responses) { double(:recent_survey_responses) }
    let(:maintenance_reports) { double(:maintenance_reports, count: 4) }
    let(:since) { double(:since) }

    before do
      allow(program).to receive(:survey_responses) { survey_responses }
      allow(survey_responses).to receive(:since).with(since) { recent_survey_responses }
      allow(filter_form).to receive(:since) { since }
      allow(recent_survey_responses).to receive(:maintenance_report) { maintenance_reports }
    end

    it 'returns the maintenance_report count for the specified program' do
      expect(dashboard.maintenance_report_survey_response_count).to eq 4
      expect(dashboard.maintenance_report_survey_response_count).to eq 4

      expect(program).to have_received(:survey_responses).once
    end
  end

  describe '#overdue_ticket_count' do
    let(:tickets) { double(:tickets, non_deleted: non_deleted_tickets) }
    let(:non_deleted_tickets) { double(:non_deleted_tickets, overdue: overdue_tickets) }
    let(:overdue_tickets) { double(:tickets, count: 23) }

    before do
      allow(program).to receive(:tickets) { tickets }
    end

    it 'returns the needs_maintenance count for the specified program' do
      expect(dashboard.overdue_ticket_count).to eq 23
      expect(dashboard.overdue_ticket_count).to eq 23

      expect(program).to have_received(:tickets).once
    end
  end

  describe '#due_soon_ticket_count' do
    let(:tickets) { double(:tickets, non_deleted: non_deleted_tickets) }
    let(:non_deleted_tickets) { double(:non_deleted_tickets, due_soon: due_soon_tickets) }
    let(:due_soon_tickets) { double(:tickets, count: 24) }

    before do
      allow(program).to receive(:tickets) { tickets }
    end

    it 'returns the needs_maintenance count for the specified program' do
      expect(dashboard.due_soon_ticket_count).to eq 24
      expect(dashboard.due_soon_ticket_count).to eq 24

      expect(program).to have_received(:tickets).once
    end
  end

  describe '#incomplete_ticket_count' do
    let(:tickets) { double(:tickets, non_deleted: non_deleted_tickets) }
    let(:non_deleted_tickets) { double(:non_deleted_tickets, incomplete: incomplete_tickets) }
    let(:incomplete_tickets) { double(:tickets, count: 24) }

    before do
      allow(program).to receive(:tickets) { tickets }
    end

    it 'returns the needs_maintenance count for the specified program' do
      expect(dashboard.incomplete_ticket_count).to eq 24
      expect(dashboard.incomplete_ticket_count).to eq 24

      expect(program).to have_received(:tickets).once
    end
  end

  describe '#program_name' do
    specify do
      expect(dashboard.program_name).to eq 'Program Name'
    end
  end

  describe '#bounds' do
    before do
      allow(filter_form).to receive(:bounds) { [1, 2, 5, 6] }
    end

    it 'delegates to the filter form' do
      expect(dashboard.bounds).to eq [1, 2, 5, 6]
    end
  end
end
