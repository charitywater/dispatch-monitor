require 'spec_helper'

describe 'Authorization', :integration do
  describe 'as a program manager' do
    let(:program_manager) { create(:account, :program_manager) }
    let(:application_settings) { ApplicationSettings.create }

    let(:my_project) { create(:project, program: program_manager.program) }
    let(:my_survey_response) { create(:survey_response, project: my_project) }
    let(:my_ticket) { create(:ticket, survey_response: my_survey_response) }

    let(:other_project) { create(:project) }
    let(:other_ticket) { create(:ticket) }

    let(:sensor) { create(:sensor) }

    before do
      post account_session_path, account: { email: program_manager.email, password: program_manager.password }
    end

    it 'prohibits viewing other people’s projects' do
      get map_project_path(other_project)
      expect(response.code).to eq '302'
    end

    it 'prohibits viewing other people’s tickets' do
      get ticket_path(other_ticket)
      expect(response.code).to eq '302'
    end

    it 'prohibits creating a ticket for other people’s projects' do
      post project_tickets_path(other_project), ticket: { dummy: 'value' }
      expect(response.code).to eq '403'
    end

    it 'prohibits updating other people’s tickets' do
      patch complete_ticket_path(other_ticket), ticket: { dummy: 'value' }
      expect(response.code).to eq '403'
    end

    it 'prohibits deleting people’s tickets' do
      delete ticket_path(other_ticket)
      expect(response.code).to eq '403'
    end

    it 'prohibits deleting own tickets' do
      delete ticket_path(my_ticket)
      expect(response.code).to eq '403'
    end

    it 'prohibits viewing the accounts page' do
      get admin_accounts_path
      expect(response.code).to eq '302'
    end

    it 'prohibits viewing the new account page' do
      get new_admin_account_path
      expect(response.code).to eq '302'
    end

    it 'prohibits creating accounts' do
      post admin_accounts_path, account: { dummy: 'value' }
      expect(response.code).to eq '403'
    end

    it 'prohibits editing accounts' do
      get edit_admin_account_path(program_manager)
      expect(response.code).to eq '302'
    end

    it 'prohibits updating accounts' do
      patch admin_account_path(program_manager)
      expect(response.code).to eq '403'
    end

    it 'prohibits deleting accounts' do
      delete admin_account_path(program_manager)
      expect(response.code).to eq '403'
    end

    it 'prohibits viewing the sensors page' do
      get sensors_path
      expect(response.code).to eq '302'
    end

    it 'prohibits viewing the new sensor page' do
      get new_sensor_path
      expect(response.code).to eq '302'
    end

    it 'prohibits creating sensors' do
      post sensors_path, sensor_project: { dummy: 'value' }
      expect(response.code).to eq '403'
    end

    it 'prohibits deleting sensors' do
      delete sensor_path(sensor)
      expect(response.code).to eq '403'
    end

    it 'prohibits viewing application settings' do
      get edit_admin_application_settings_path
      expect(response.code).to eq '302'
    end

    it 'prohibits updating application settings' do
      patch admin_application_settings_path, application_settings: { dummy: 'value' }
      expect(response.code).to eq '403'
    end

    it 'prohibits viewing the import project page' do
      get new_import_project_path
      expect(response.code).to eq '302'
    end

    it 'prohibits importing projects' do
      post import_projects_path
      expect(response.code).to eq '403'
    end

    it 'prohibits viewing the import survey response page' do
      get new_import_survey_path
      expect(response.code).to eq '302'
    end

    it 'prohibits importing survey responses' do
      post import_surveys_path
      expect(response.code).to eq '403'
    end
  end
end
