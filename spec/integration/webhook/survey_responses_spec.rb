require 'spec_helper'

describe 'Survey responses webhook', :integration do
  include Capybara::Email::DSL

  let(:project) { Project.first }
  let(:sensor) { Sensor.first }
  let(:sensor_project_assigner) { RemoteMonitoring::PostProcessor::SensorProjectAssigner.new }
  let(:spreadsheet) {
    [
      ["ID", "IMEI", "SIM type", "Batch", "Location", "BT config", "PCH FA Test Pass", "Form", "Installed", "Status", "Comments", nil],
      ["DVT999", "013949004626811", "BT", "DVT1", nil, "OK", nil, nil, nil, nil, nil, nil],
      ["DVT005", "013949004661818", "BT", "DVT2", nil, "OK", nil, nil, nil, nil, nil, nil],
      ["DVT006", "013949004628262", "BT", "DVT3", nil, "OK", nil, nil, nil, nil, nil, nil]
    ]
  }

  let(:source_observation_response) do
    SurveyResponse.find_by(survey_type: 'test_source_observation_v02')
  end

  let(:maintenance_report_response) do
    SurveyResponse.find_by(survey_type: 'test_maintenance_report_v02')
  end

  let(:sensor_registration_response) do
    SensorRegistrationResponse.find_by(survey_type: 'test_sensor_registration_afd1')
  end

  before do
    clear_emails
  end

  context 'a new sensor is registered' do
    before do
      create(:sensor, device_id: "DVT999", imei: "013949004626811")
      create(:project, deployment_code: "ET.GOH.Q4.09.048.123")
      allow(CSV).to receive(:read).and_return(spreadsheet) # mock CSV.read call
      allow(sensor_project_assigner).to receive(:import_project) { project } # mock wazi import

      post webhook_survey_responses_path, sensor_registration_data(
        device_id: "DVT999",
        error_code: "oH"
      )
    end

    it 'assigns the sensor' do
      expect(sensor.imei).to eq "013949004626811"
      expect(sensor.project.deployment_code).to eq "ET.GOH.Q4.09.048.123"
    end
  end

  context 'source observation status is flowing' do
    before do
      post webhook_survey_responses_path, source_observation_data(
        flowing_water: 'Yes',
        consumable_water: 'Yes',
        maintenance_visit: 'No'
      )
    end

    it 'imports the survey’s project with the "flowing" status' do
      expect(project.deployment_code).to eq 'ET.GOH.Q4.09.048.123'
      expect(project).to be_flowing

      expect(project.country.name).to eq 'Ethiopia'
      expect(project.partner.name).to eq 'Relief Society of Tigray'
    end

    it 'creates a survey response' do
      expect(SurveyResponse.where(survey_type: 'test_source_observation_v02').count).to eq 1
      expect(SurveyResponse.where(survey_type: 'test_maintenance_report_v02').count).to eq 0

      expect(source_observation_response.fs_survey_id).to eq 75507
      expect(source_observation_response.fs_response_id).to eq 1
    end

    it 'creates the activities' do
      expect(project.activities.observation_survey_received.count).to eq 1
      expect(project.activities.maintenance_report_received.count).to eq 0

      expect(project.activities.status_changed_to_flowing.count).to eq 1
      expect(project.activities.status_changed.count).to eq 1
    end

    it 'does not create a ticket' do
      expect(project.tickets.count).to eq 0
    end

    it 'does not send an email' do
      expect(all_emails).to be_empty
    end
  end

  context 'source observation status is needs_visit' do
    before do
      post webhook_survey_responses_path, source_observation_data(
        flowing_water: 'Yes',
        consumable_water: 'Yes',
        maintenance_visit: 'Yes'
      )
    end

    it 'imports the survey’s project with the "needs_visit" status' do
      expect(project.deployment_code).to eq 'ET.GOH.Q4.09.048.123'
      expect(project).to be_needs_visit
    end

    it 'creates the activities' do
      expect(project.activities.observation_survey_received.count).to eq 1
      expect(project.activities.maintenance_report_received.count).to eq 0

      expect(project.activities.status_changed_to_needs_visit.count).to eq 1
      expect(project.activities.status_changed.count).to eq 1
    end

    it 'creates a ticket' do
      expect(project.tickets.incomplete.count).to eq 1
      expect(project.tickets.complete.count).to eq 0
    end

    it 'does not send an email' do
      expect(all_emails).to be_empty
    end

    context 'maintenance report repair successful' do
      context 'maintenance report status is flowing' do
        before do
          clear_emails

          post webhook_survey_responses_path, maintenance_report_data(
            repairs_successful: 'Yes',
            flowing_water: 'Yes',
            consumable_water: 'Yes',
            maintenance_visit: 'No',
          )
        end

        it 'changes the project status to "flowing"' do
          expect(project).to be_flowing
        end

        it 'creates the activities' do
          expect(project.activities.observation_survey_received.count).to eq 1
          expect(project.activities.maintenance_report_received.count).to eq 1

          expect(project.activities.status_changed_to_flowing.count).to eq 1
          expect(project.activities.status_changed_to_needs_visit.count).to eq 1
          expect(project.activities.status_changed.count).to eq 2
        end

        it 'completes the tickets' do
          expect(project.tickets.incomplete.count).to eq 0
          expect(project.tickets.complete.count).to eq 1
        end

        it 'does not send an email' do
          expect(all_emails).to be_empty
        end
      end

      context 'maintenance report status is needs_visit' do
        before do
          clear_emails

          post webhook_survey_responses_path, maintenance_report_data(
            repairs_successful: 'Yes',
            flowing_water: 'Yes',
            consumable_water: 'No',
            maintenance_visit: 'No',
          )
        end

        it 'changes the project status to "needs_visit"' do
          expect(project).to be_needs_visit
        end

        it 'creates the activities' do
          expect(project.activities.observation_survey_received.count).to eq 1
          expect(project.activities.maintenance_report_received.count).to eq 1

          expect(project.activities.status_changed_to_needs_visit.count).to eq 1
          expect(project.activities.status_changed.count).to eq 1
        end

        it 'completes the tickets' do
          expect(project.tickets.complete.count).to eq 1
        end

        it 'creates a new ticket' do
          expect(project.tickets.incomplete.count).to eq 1
        end

        it 'does not send an email' do
          expect(all_emails).to be_empty
        end
      end

      context 'maintenance report status is needs_maintenance' do
        before do
          clear_emails

          post webhook_survey_responses_path, maintenance_report_data(
            repairs_successful: 'Yes',
            flowing_water: 'No',
            consumable_water: 'Yes',
            maintenance_visit: 'Yes',
          )
        end

        it 'changes the project status to "needs_maintenance"' do
          expect(project).to be_needs_maintenance
        end

        it 'creates the activities' do
          expect(project.activities.observation_survey_received.count).to eq 1
          expect(project.activities.maintenance_report_received.count).to eq 1

          expect(project.activities.status_changed_to_needs_visit.count).to eq 1
          expect(project.activities.status_changed_to_needs_maintenance.count).to eq 1
          expect(project.activities.status_changed.count).to eq 2
        end

        it 'completes the old tickets' do
          expect(project.tickets.complete.count).to eq 1
        end

        it 'creates a new ticket' do
          expect(project.tickets.incomplete.count).to eq 1
        end

        it 'sends an email' do
          open_email('test@example.com')
          expect(current_email.subject).to include '(ET.GOH.Q4.09.048.123) needs maintenance'
        end
      end
    end

    context 'maintenance report repair unsuccessful' do
      context 'maintenance report is now "Inactive"' do
        before do
          clear_emails

          post webhook_survey_responses_path, maintenance_report_data(
            repairs_successful: 'No',
            unsuccessful_repair_reason: 'Complete rehabilitation is needed',
            flowing_water: 'Yes',
            consumable_water: 'Yes',
            maintenance_visit: 'No',
          )
        end

        it 'changes the project status to "Inactive"' do
          expect(project).to be_inactive
        end

        it 'creates the activities' do
          expect(project.activities.observation_survey_received.count).to eq 1
          expect(project.activities.maintenance_report_received.count).to eq 1

          expect(project.activities.status_changed_to_needs_visit.count).to eq 1
          expect(project.activities.status_changed_to_inactive.count).to eq 1
          expect(project.activities.status_changed.count).to eq 2
        end

        it 'completes the old tickets' do
          expect(project.tickets.complete.count).to eq 1
        end

        it 'does not create a new ticket' do
          expect(project.tickets.incomplete.count).to eq 0
        end

        it 'does not send an email' do
          expect(all_emails).to be_empty
        end
      end

      context 'maintenance report is not now "Inactive"' do
        before do
          clear_emails

          post webhook_survey_responses_path, maintenance_report_data(
            repairs_successful: 'No',
            unsuccessful_repair_reason: 'Need more time, tools or spare parts',
            flowing_water: 'Yes',
            consumable_water: 'Yes',
            maintenance_visit: 'No',
          )
        end

        it 'changes the project status to "needs_maintenance"' do
          expect(project).to be_needs_maintenance
        end

        it 'creates a survey response' do
          expect(SurveyResponse.where(survey_type: 'test_source_observation_v02').count).to eq 1
          expect(SurveyResponse.where(survey_type: 'test_maintenance_report_v02').count).to eq 1

          expect(maintenance_report_response.fs_survey_id).to eq 76026
          expect(maintenance_report_response.fs_response_id).to eq 2
        end

        it 'creates the activities' do
          expect(project.activities.observation_survey_received.count).to eq 1
          expect(project.activities.maintenance_report_received.count).to eq 1

          expect(project.activities.status_changed_to_needs_visit.count).to eq 1
          expect(project.activities.status_changed_to_needs_maintenance.count).to eq 1
          expect(project.activities.status_changed.count).to eq 2
        end

        it 'completes the old tickets' do
          expect(project.tickets.complete.count).to eq 1
        end

        it 'creates a new ticket' do
          expect(project.tickets.incomplete.count).to eq 1
        end

        it 'sends an email with the project information' do
          open_email('test@example.com')
          expect(current_email.subject).to match(/Repairs at .* \(ET.GOH.Q4.09.048.123\) were unsuccessful/)
        end
      end
    end
  end

  context 'source observation status is needs_maintenance' do
    before do
      post webhook_survey_responses_path, source_observation_data(
        flowing_water: 'No',
        consumable_water: 'Yes',
        maintenance_visit: 'Yes'
      )
    end

    it 'imports the survey’s project with the "needs_maintenance" status' do
      expect(project.deployment_code).to eq 'ET.GOH.Q4.09.048.123'
      expect(project).to be_needs_maintenance
    end

    it 'creates a ticket' do
      expect(project.tickets.incomplete.count).to eq 1
      expect(project.tickets.complete.count).to eq 0
    end

    it 'creates the activities' do
      expect(project.activities.observation_survey_received.count).to eq 1
      expect(project.activities.maintenance_report_received.count).to eq 0

      expect(project.activities.status_changed_to_needs_maintenance.count).to eq 1
      expect(project.activities.status_changed.count).to eq 1
    end

    it 'sends an email with the project information' do
      open_email('test@example.com')
      expect(current_email.subject).to include '(ET.GOH.Q4.09.048.123) needs maintenance'
    end

    context 'maintenance report repair successful' do
      context 'maintenance report status is flowing' do
        before do
          clear_emails

          post webhook_survey_responses_path, maintenance_report_data(
            repairs_successful: 'Yes',
            flowing_water: 'Yes',
            consumable_water: 'Yes',
            maintenance_visit: 'No',
          )
        end

        it 'changes the project status to "flowing"' do
          expect(project).to be_flowing
        end

        it 'creates the activities' do
          expect(project.activities.observation_survey_received.count).to eq 1
          expect(project.activities.maintenance_report_received.count).to eq 1

          expect(project.activities.status_changed_to_needs_maintenance.count).to eq 1
          expect(project.activities.status_changed_to_flowing.count).to eq 1
          expect(project.activities.status_changed.count).to eq 2
        end

        it 'completes the tickets' do
          expect(project.tickets.incomplete.count).to eq 0
          expect(project.tickets.complete.count).to eq 1
        end

        it 'does not send an email' do
          expect(all_emails).to be_empty
        end
      end

      context 'maintenance report status is needs_visit' do
        before do
          clear_emails

          post webhook_survey_responses_path, maintenance_report_data(
            repairs_successful: 'Yes',
            flowing_water: 'Yes',
            consumable_water: 'No',
            maintenance_visit: 'No',
          )
        end

        it 'changes the project status to "needs_visit"' do
          expect(project).to be_needs_visit
        end

        it 'creates the activities' do
          expect(project.activities.observation_survey_received.count).to eq 1
          expect(project.activities.maintenance_report_received.count).to eq 1

          expect(project.activities.status_changed_to_needs_maintenance.count).to eq 1
          expect(project.activities.status_changed_to_needs_visit.count).to eq 1
          expect(project.activities.status_changed.count).to eq 2
        end

        it 'completes the tickets' do
          expect(project.tickets.complete.count).to eq 1
        end

        it 'creates a new ticket' do
          expect(project.tickets.incomplete.count).to eq 1
        end

        it 'does not send an email' do
          expect(all_emails).to be_empty
        end
      end

      # yes, this is a weird case...
      context 'maintenance report status is needs_maintenance' do
        before do
          clear_emails

          post webhook_survey_responses_path, maintenance_report_data(
            repairs_successful: 'Yes',
            flowing_water: 'No',
            consumable_water: 'Yes',
            maintenance_visit: 'Yes',
          )
        end

        it 'changes the project status to "needs_visit"' do
          expect(project).to be_needs_maintenance
        end

        it 'creates the activities' do
          expect(project.activities.observation_survey_received.count).to eq 1
          expect(project.activities.maintenance_report_received.count).to eq 1

          expect(project.activities.status_changed_to_needs_maintenance.count).to eq 1
          expect(project.activities.status_changed.count).to eq 1
        end

        it 'completes the ticket' do
          expect(project.tickets.complete.count).to eq 1
        end

        it 'creates a new ticket' do
          expect(project.tickets.incomplete.count).to eq 1
        end

        it 'sends an email' do
          open_email('test@example.com')
          expect(current_email.subject).to include '(ET.GOH.Q4.09.048.123) needs maintenance'
        end
      end
    end

    context 'maintenance report repair unsuccessful' do
      context 'maintenance report is now "Inactive"' do
        before do
          clear_emails

          post webhook_survey_responses_path, maintenance_report_data(
            repairs_successful: 'No',
            unsuccessful_repair_reason: 'Complete rehabilitation is needed',
            flowing_water: 'Yes',
            consumable_water: 'Yes',
            maintenance_visit: 'No',
          )
        end

        it 'changes the project status to "Inactive"' do
          expect(project).to be_inactive
        end

        it 'creates the activities' do
          expect(project.activities.observation_survey_received.count).to eq 1
          expect(project.activities.maintenance_report_received.count).to eq 1

          expect(project.activities.status_changed_to_needs_maintenance.count).to eq 1
          expect(project.activities.status_changed_to_inactive.count).to eq 1
          expect(project.activities.status_changed.count).to eq 2
        end

        it 'completes the tickets' do
          expect(project.tickets.complete.count).to eq 1
          expect(project.tickets.incomplete.count).to eq 0
        end

        it 'does not send an email' do
          expect(all_emails).to be_empty
        end
      end

      context 'maintenance report is not now "Inactive"' do
        before do
          clear_emails

          post webhook_survey_responses_path, maintenance_report_data(
            repairs_successful: 'No',
            unsuccessful_repair_reason: 'Need more time, tools or spare parts',
            flowing_water: 'Yes',
            consumable_water: 'Yes',
            maintenance_visit: 'No',
          )
        end

        it 'leaves the project status as "needs_maintenance"' do
          expect(project).to be_needs_maintenance
        end

        it 'does not create a new activity' do
          expect(project.activities.observation_survey_received.count).to eq 1
          expect(project.activities.maintenance_report_received.count).to eq 1

          expect(project.activities.status_changed_to_needs_maintenance.count).to eq 1
          expect(project.activities.status_changed.count).to eq 1
        end

        it 'does not complete the old tickets' do
          expect(project.tickets.complete.count).to eq 0
        end

        it 'does not create a new ticket' do
          expect(project.tickets.incomplete.count).to eq 1
        end

        it 'sends an email saying the repair was unsuccessful' do
          open_email('test@example.com')
          expect(current_email.subject).to match(/Repairs at .* \(ET.GOH.Q4.09.048.123\) were unsuccessful/)
        end
      end
    end
  end

  def source_observation_data(answers)
    {
      "_id" => survey_response_id,
      "PV5RcUw2ys" => answers[:flowing_water],
      "5pXGXZwpaI" => answers[:consumable_water],
      "LkUlwEuUwP" => answers[:maintenance_visit],
    }.merge(default_source_observation_answers)
  end

  def maintenance_report_data(answers)
    {
      "_id" => survey_response_id,
      "6yIG9h9Lqk" => answers[:repairs_successful],
      "J390tGE6go" => answers[:unsuccessful_repair_reason],
      "JOtRvhF37z" => answers[:flowing_water],
      "JkuCA9JrTB" => answers[:consumable_water],
      "gshGGAKc8i" => answers[:maintenance_visit],
    }.merge(default_maintenance_report_answers)
  end

  def default_source_observation_answers
    @default_source_observation_answers ||= {
      "_created_at" => "2014-06-26T19:24:21+00:00",
      "icJ0bt2hs1_0" => "ET",
      "icJ0bt2hs1_1" => "GOH",
      "icJ0bt2hs1_2" => "Q4",
      "icJ0bt2hs1_3" => "09",
      "icJ0bt2hs1_4" => "048",
      "icJ0bt2hs1_5" => "123",
      "icJ0bt2hs1_6" => "000",
      "survey_type" => "test_source_observation_v02",
      "XBriGBeCyP" => "Hand pump: Afridev", # inventory type
      "webhook" => "true",
    }
  end

  def default_maintenance_report_answers
    @default_maintenance_report_answers ||= {
      "_created_at" => "2014-06-30T16:27:59+00:00",
      "rXB5grAKHT_0" => "ET",
      "rXB5grAKHT_1" => "GOH",
      "rXB5grAKHT_2" => "Q4",
      "rXB5grAKHT_3" => "09",
      "rXB5grAKHT_4" => "048",
      "rXB5grAKHT_5" => "123",
      "rXB5grAKHT_6" => "000",
      "HOUKL73PP6" => "Hand pump: Afridev", # inventory type
      "survey_type" => "test_maintenance_report_v02",
      "webhook" => "true",
    }
  end

  def sensor_registration_data(answers)
    {
      "_id" => survey_response_id,
      "CFDuMWqytJ" => answers[:device_id],
      "0oLTpi9Goh" => answers[:error_code]
    }.merge(default_sensor_registration_answers)
  end

  def default_sensor_registration_answers
    @default_sensor_registration_answers ||= {
      "_created_at" => "2014-07-30T16:27:59+00:00",
      "TBLwLK3wL8_0" => "ET",
      "TBLwLK3wL8_1" => "GOH",
      "TBLwLK3wL8_2" => "Q4",
      "TBLwLK3wL8_3" => "09",
      "TBLwLK3wL8_4" => "048",
      "TBLwLK3wL8_5" => "123",
      "survey_type" => "test_sensor_registration_afd1",
      "webhook" => "true",
    }
  end

  def survey_response_id
    @survey_response_id ||= 0
    @survey_response_id += 1
  end
end
