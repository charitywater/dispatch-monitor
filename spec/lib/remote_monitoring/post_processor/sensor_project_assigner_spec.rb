require 'spec_helper'

module RemoteMonitoring
  module PostProcessor
    describe SensorProjectAssigner do
      let(:sensor_project_assigner) { SensorProjectAssigner.new }

      describe '#process' do
        let!(:submitted_at) { 7.days.ago }
        let(:deployment_code) { "ET.GOH.Q4.09.148.001" }

        let(:policy) do
          double(
            :policy,
            device_number: "DVT004",
            happened_at: submitted_at,
            deployment_code: deployment_code,
            valid_deployment_code?: true,
            spreadsheet_exists?: true,
            network_error?: false,
            assign_sensor?: true,
            sensor_registration_response: sensor_registration_response,
          )
        end

        let!(:sensor_registration_response) do
          create(
            :sensor_registration_response,
            :sensor_registration_afd1,
            id: 3,
            submitted_at: submitted_at,
          )
        end

        let(:spreadsheet) {
          [
            ["ID", "IMEI", "SIM type", "Batch", "Location", "BT config", "PCH FA Test Pass", "Form", "Installed", "Status", "Comments", nil],
            ["DVT004", "013949004626811", "BT", "DVT1", nil, "OK", nil, nil, nil, nil, nil, nil],
            ["DVT005", "013949004661818", "BT", "DVT2", nil, "OK", nil, nil, nil, nil, nil, nil],
            ["DVT006", "013949004628262", "BT", "DVT3", nil, "OK", nil, nil, nil, nil, nil, nil]
          ]
        }
        let(:imei) { "013949004626811" }

        context 'project exists in the system' do
          before do
            @sensor = create(:sensor, device_id: 'asdf', imei: '013949004626811', project: nil)
            @project = create(:project, deployment_code: deployment_code)
            allow(Sensor).to receive(:find_by) { @sensor }
            allow(CSV).to receive(:read).and_return(spreadsheet) # mock CSV.read call
            allow(sensor_project_assigner).to receive(:import_project) { @project } # mock wazi import
          end

          it 'assigns the sensor to the project' do
            sensor_project_assigner.process(policy)

            expect(@sensor.project.deployment_code).to eq deployment_code
          end

          it 'updates the device_id on the sensor' do
            sensor_project_assigner.process(policy)

            expect(@sensor.device_id).to eq 'DVT004'
          end
        end

        context 'project does not exist and needs to be imported' do
          before do
            @sensor = create(:sensor, device_id: 'DVT004', imei: '013949004626811', project: nil)
            allow(Sensor).to receive(:find_by) { @sensor }

            allow(CSV).to receive(:read).and_return(spreadsheet)
            allow(sensor_project_assigner).to receive(:import_project) { create(:project, deployment_code: deployment_code) }
          end

          it 'imports the project' do
            expect(Project.count).to eq 0
            sensor_project_assigner.process(policy)
            expect(Project.count).to eq 1 # ensure the new project is imported
          end

          it 'assigns the sensor to the project' do
            sensor_project_assigner.process(policy)
            expect(@sensor.project.deployment_code).to eq deployment_code
          end
        end
      end
    end
  end
end