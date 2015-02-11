require 'spec_helper'

describe SensorProject do
  let(:sensor_project) { SensorProject.new }

  describe 'validations' do
    describe 'device_id' do
      context 'device does not exist' do
        specify do
          sensor_project.device_id = "123456789"
          sensor_project.valid?

          expect(sensor_project.errors[:device_id]).to be_empty
        end
      end

      context 'device already exists' do
        before do
          create(:sensor, device_id: "123456789")
        end

        specify do
          sensor_project.device_id = "123456789"
          sensor_project.valid?

          expect(sensor_project.errors[:device_id]).to eq ['device id already in use']
        end
      end
    end

    describe 'imei' do
      context 'device does not exist' do
        specify do
          sensor_project.imei = "013777007477969"
          sensor_project.valid?

          expect(sensor_project.errors[:imei]).to be_empty
        end
      end

      context 'device already exists' do
        before do
          create(:sensor, imei: "013777007477969")
        end

        specify do
          sensor_project.imei = "013777007477969"
          sensor_project.valid?

          expect(sensor_project.errors[:imei]).to eq ['imei already in use']
        end
      end
    end

    describe 'deployment_code' do
      context 'project exists' do
        before do
          create(:project, deployment_code: 'BB.BBB.Q1.11.111.111')
        end

        specify do
          sensor_project.deployment_code = 'BB.BBB.Q1.11.111.111'
          sensor_project.valid?

          expect(sensor_project.errors[:deployment_code]).to be_empty
        end
      end

      context 'project does not exist' do
        specify do
          sensor_project.deployment_code = 'BB.BBB.Q1.11.111.111'
          sensor_project.valid?

          expect(sensor_project.errors[:deployment_code]).to eq ['does not exist']
        end
      end

      context 'project already has a sensor' do
        before do
          project = create(:project, deployment_code: 'BB.BBB.Q1.11.111.111')
          create(:sensor, project: project, device_id: '1234', imei: '0123456789')
        end

        specify do
          sensor_project.deployment_code = 'BB.BBB.Q1.11.111.111'
          sensor_project.valid?

          expect(sensor_project.errors[:deployment_code]).to eq ['already has a sensor']
        end
      end
    end
  end

  describe '#save' do
    let!(:project) { create(:project, deployment_code: 'BB.BBB.Q1.11.111.111') }

    before do
      allow(sensor_project).to receive(:valid?) { valid }

      sensor_project.imei = "013777007477969"
      sensor_project.deployment_code = project.deployment_code
    end

    context 'when valid' do
      let(:valid) { true }

      it 'creates the sensor' do
        sensor_project.save

        sensor = Sensor.last
        expect(sensor.imei).to eq "013777007477969"
        expect(sensor.project).to eq project
      end
    end

    context 'when invalid' do
      let(:valid) { false }

      it 'does not create the sensor' do
        expect { sensor_project.save }.not_to change { Sensor.count }
      end
    end
  end
end
