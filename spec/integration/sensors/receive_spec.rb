require 'spec_helper'

describe 'BodyTrace receive endpoint', :integration do
  let(:json_request) do
    File.read(Rails.root.join('spec', 'fixtures', 'sensors.json'))
  end
  let(:json_request_raw) do
    File.read(Rails.root.join('spec', 'fixtures', 'sensors_raw.json'))
  end

  before do
    create(:sensor, device_id: "1289600793682", imei: "013949004634708")
  end

  it 'updates the sensor with the new information' do
    sensor = Sensor.find_by(imei: "013949004634708")
    expect(sensor.weekly_logs.count).to eq 0

    post '/sensors/receive', json_request

    expect(sensor.weekly_logs.count).to eq 1
    expect(sensor.weekly_logs.pluck(:week)).to eq [25]
    expect(sensor.weekly_logs.first.daily_logs.count).to eq 7
    expect(
      sensor.weekly_logs.first.daily_logs.all? do |day|
        day['liters'].count == 24
      end
    ).to eq true
  end

  it 'updates the sensor with the new information from a raw data packet' do
    sensor = Sensor.find_by(imei: "013949004634708")
    expect(sensor.weekly_logs.count).to eq 0

    post '/sensors/receive', json_request_raw

    expect(sensor.weekly_logs.count).to eq 1
  end
end
