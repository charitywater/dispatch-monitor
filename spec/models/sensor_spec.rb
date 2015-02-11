require 'spec_helper'

describe Sensor do
  let(:sensor) { Sensor.new }

  describe 'associations' do
    specify do
      expect(sensor).to belong_to(:project)
    end

    specify do
      expect(sensor).to have_many(:weekly_logs).dependent(:destroy)
    end
  end

  describe 'validations' do
    specify do
      expect(sensor).to validate_presence_of(:imei)
    end

    specify do
      create(:sensor)

      expect(sensor).to validate_uniqueness_of(:imei)
    end
  end

  describe '#deployment_code' do
    let(:deployment_code) { 'AA.AAA.Q1.11.111.111' }
    let(:project) { build(:project, deployment_code: deployment_code) }

    before do
      sensor.project = project
    end

    it 'returns the project’s deployment code' do
      expect(sensor.deployment_code).to eq deployment_code
    end
  end

  describe '#community_name' do
    let(:community_name) { 'Fancy Community' }
    let(:project) { build(:project, community_name: community_name) }

    before do
      sensor.project = project
    end

    it 'returns the project’s community name' do
      expect(sensor.community_name).to eq community_name
    end
  end

  describe '#uptime' do
    let(:sensor) { create(:sensor, device_id: 5, imei: "013949004634708") }

    before do
      create(:weekly_log, sensor: sensor, week: 25)
      create(:weekly_log, sensor: sensor, week: 20)
    end

    it 'returns the week from the last daily log' do
      expect(sensor.uptime).to eq 20
    end
  end

  describe '#daily_average_liters' do
    let(:sensor) { create(:sensor, device_id: 5, imei: "013949004634708") }

    before do
      create(:weekly_log, sensor: sensor, liters: (11...18).to_a)
      create(:weekly_log, sensor: sensor, liters: (31...38).to_a)
    end

    it 'returns the daily average' do
      expect(sensor.daily_average_liters).to eq 24.0
    end
  end
end
