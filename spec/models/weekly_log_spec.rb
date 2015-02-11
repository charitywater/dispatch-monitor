require 'spec_helper'

describe WeeklyLog do
  let(:weekly_log) do
    WeeklyLog.new(
      data: {
        'values' => {
          'weeklyLog' => {
            'dailyLogs' => []
          }
        }
      }
    )
  end

  describe 'validations' do
    specify do
      expect(weekly_log).to validate_presence_of(:sensor_id)
    end
  end

  describe 'associations' do
    specify do
      expect(weekly_log).to belong_to(:sensor)
    end

    specify do
      expect(weekly_log).to have_one(:ticket)
    end

    specify do
      expect(weekly_log).to have_one(:project).through(:sensor)
    end
  end

  describe 'callbacks' do
    let!(:sensor) { create(:sensor) }

    describe 'after create' do
      before do
        weekly_log.sensor = sensor
        weekly_log.data = {
          'values' => {
            'weeklyLog' => {
              'dailyLogs' => [
                { 'liters' => [1, 2, 3] },
                { 'liters' => [11, 12, 13] },
                { 'liters' => [1, 2, 3] },
                { 'liters' => [11, 12, 13] },
                { 'liters' => [1, 2, 3] },
                { 'liters' => [11, 12, 13] },
                { 'liters' => [1, 2, 3] },
              ]
            }
          }
        }
      end

      context 'when the sensor’s daily average liters is blank' do
        before do
          sensor.update(
            daily_average_liters: nil,
            days_for_daily_average_liters: nil,
          )
        end

        it 'populates the daily_average_liters fields with the data of the current weekly log' do
          weekly_log.save

          sensor.reload
          expect(sensor.daily_average_liters).to be_within(0.1).of(18.857142)
          expect(sensor.days_for_daily_average_liters).to eq 7
        end
      end

      context 'when the sensor has previously calculated daily average liters' do
        before do
          sensor.update(
            daily_average_liters: 22.5,
            days_for_daily_average_liters: 3,
          )
        end

        it 'updates the daily_average_liters fields' do
          weekly_log.save

          sensor.reload
          expect(sensor.daily_average_liters).to be_within(0.1).of(19.95)
          expect(sensor.days_for_daily_average_liters).to eq 10
        end

        context 'when the sensor has previously calculated daily average liters and the current weekly is out-of-band' do
          before do
            weekly_log.red_flag = WeeklyLog::OUT_OF_BAND_RED_FLAG
          end

          it 'does not update the sensor’s daily average values' do
            weekly_log.save
            sensor.reload

            expect(sensor.daily_average_liters).to eq 22.5
            expect(sensor.days_for_daily_average_liters).to eq 3
          end
        end
      end

      it 'caches the week as the sensor uptime' do
        sensor.update(uptime: 30)
        weekly_log.week = 35
        weekly_log.save

        sensor.reload
        expect(sensor.uptime).to eq 35
      end
    end
  end

  describe '.since' do
    let!(:older_log) { create(:weekly_log, week_started_at: 5.weeks.ago.beginning_of_week(:sunday)) }
    let!(:boundary)  { create(:weekly_log, week_started_at: 4.weeks.ago.beginning_of_week(:sunday)) }
    let!(:newer_log) { create(:weekly_log, week_started_at: 3.weeks.ago.beginning_of_week(:sunday)) }

    it 'returns the weekly logs submitted after the specified datetime' do
      expect(WeeklyLog.since(4.weeks.ago)).to match_array [boundary, newer_log]
    end
  end

  describe '.out_of_band' do
    let!(:out_of_band) { create(:weekly_log, red_flag: WeeklyLog::OUT_OF_BAND_RED_FLAG) }
    let!(:in_band) { create(:weekly_log, red_flag: 0) }

    it 'returns the weekly logs with a red_flag of WeeklyLog::OUT_OF_BAND_RED_FLAG' do
      expect(WeeklyLog.out_of_band).to eq [out_of_band]
    end
  end

  describe '.in_band' do
    let!(:out_of_band) { create(:weekly_log, red_flag: WeeklyLog::OUT_OF_BAND_RED_FLAG) }
    let!(:in_band) { create(:weekly_log, red_flag: 0) }

    it 'returns the weekly logs with a red_flag of WeeklyLog::OUT_OF_BAND_RED_FLAG' do
      expect(WeeklyLog.in_band).to eq [in_band]
    end
  end

  describe '#device_id' do
    before do
      weekly_log.data = { 'deviceId' => 12345 }
    end

    it 'returns the device id from the data' do
      expect(weekly_log.device_id).to eq 12345
    end
  end

  describe '#daily_logs' do
    before do
      weekly_log.data = {
        "values" => {
          "weeklyLog" => {
            "dailyLogs" => [
              { "liters" => [1, 2, 3], },
              { "liters" => [11, 12, 13], },
              { "liters" => [51, 52, 53], }
            ]
          }
        }
      }
    end

    it 'returns the value for "dailyLogs"' do
      expect(weekly_log.daily_logs).to eq [
        { "liters" => [1, 2, 3], },
        { "liters" => [11, 12, 13], },
        { "liters" => [51, 52, 53], }
      ]
    end
  end

  describe '#total_liters' do
    before do
      weekly_log.data = {
        "values" => {
          "weeklyLog" => {
            "dailyLogs" => [
              { "liters" => [1, 2, 3], },
              { "liters" => [11, 12, 13], },
              { "liters" => [51, 52, 53], }
            ]
          }
        }
      }
    end

    it 'sums the hourly liters' do
      expect(weekly_log.total_liters).to eq 198
    end
  end

  describe '#liters_by_day' do
    before do
      weekly_log.data = {
        "values" => {
          "weeklyLog" => {
            "dailyLogs" => [
              { "liters" => [1, 2, 3], },
              { "liters" => [11, 12, 13], },
              { "liters" => [51, 52, 53], }
            ]
          }
        }
      }
    end

    it 'returns an array of the liters drawn each day' do
      expect(weekly_log.liters_by_day).to eq [6, 36, 156]
    end
  end

  describe '#normal_flow?' do
    before do
      weekly_log.red_flag = 0
      weekly_log.data = {
        "values" => {
          "weeklyLog" => {
            "dailyLogs" => [
              { "liters" => [1, 2, 3], },
              { "liters" => [11, 12, 13], },
              { "liters" => [51, 52, 53], }
            ]
          }
        }
      }
    end

    context 'when the weekly log’s redFlag is WeeklyLog::OUT_OF_BAND_RED_FLAG' do
      before do
        weekly_log.red_flag = WeeklyLog::OUT_OF_BAND_RED_FLAG
      end

      specify do
        expect(weekly_log.normal_flow?).to be false
      end
    end

    context 'when the weekly log’s redFlag is 1' do
      before do
        weekly_log.red_flag = 1
      end

      context 'when the daily logs redFlags are all 0' do
        before do
          weekly_log.data['values']['weeklyLog']['dailyLogs'].each do |daily_log|
            daily_log['redFlag'] = 0
          end
        end

        specify do
          expect(weekly_log.normal_flow?).to be true
        end
      end

      context 'when at least one daily log redFlag is 1' do
        before do
          weekly_log.data['values']['weeklyLog']['dailyLogs'].each do |daily_log|
            daily_log['redFlag'] = 0
          end
          weekly_log.data['values']['weeklyLog']['dailyLogs'][1]['redFlag'] = 1
        end

        specify do
          expect(weekly_log.normal_flow?).to be false
        end
      end
    end

    context 'when the weekly log’s redFlag is 0' do
      before do
        weekly_log.red_flag = 0
      end

      context 'when the daily logs redFlags are all 0' do
        before do
          weekly_log.data['values']['weeklyLog']['dailyLogs'].each do |daily_log|
            daily_log['redFlag'] = 0
          end
        end

        specify do
          expect(weekly_log.normal_flow?).to be true
        end
      end

      context 'when at least one daily log redFlag is 1' do
        before do
          weekly_log.data['values']['weeklyLog']['dailyLogs'].each do |daily_log|
            daily_log['redFlag'] = 0
          end
          weekly_log.data['values']['weeklyLog']['dailyLogs'][1]['redFlag'] = 1
        end

        specify do
          expect(weekly_log.normal_flow?).to be false
        end
      end
    end
  end

  describe '#has_out_of_band_pair?' do
    let(:date) { DateTime.rfc2822('Thu, 8 Aug 2014 04:05:06 +0000') }
    let(:sensor) { create(:sensor, project: project) }
    let(:project) { create(:project) }

    before do
      Timecop.travel date

      weekly_log.update(
        unit_id: 1234,
        week_started_at: date.beginning_of_week,
        sensor: sensor,
      )
    end

    after do
      Timecop.return
    end

    context 'an out of band was received earlier this week' do
      before do
        create(
          :weekly_log,
          :out_of_band,
          week_started_at: date.beginning_of_week,
          sensor: sensor,
          unit_id: 1234,
        )
      end

      specify do
        expect(weekly_log.has_out_of_band_pair?).to eq true
      end
    end

    context 'this is an out of band packet' do
      before do
        create(
          :weekly_log,
          :out_of_band,
          week_started_at: date.beginning_of_week,
          sensor: sensor,
          unit_id: 1234,
        )

        weekly_log.red_flag = WeeklyLog::OUT_OF_BAND_RED_FLAG
      end

      specify do
        expect(weekly_log.has_out_of_band_pair?).to eq false
      end
    end

    context 'an out of band was received the previous week' do
      before do
        create(
          :weekly_log,
          :out_of_band,
          week_started_at: date.beginning_of_week - 7.days,
          sensor: sensor,
          unit_id: 1234,
        )
      end

      specify do
        expect(weekly_log.has_out_of_band_pair?).to eq false
      end
    end

    context 'an out of band was received the following week' do
      before do
        create(
          :weekly_log,
          :out_of_band,
          week_started_at: date.beginning_of_week + 7.days,
          sensor: sensor,
          unit_id: 1234,
        )
      end

      specify do
        expect(weekly_log.has_out_of_band_pair?).to eq false
      end
    end

    context 'an out of band was received this week for a different unit' do
      before do
        create(
          :weekly_log,
          :out_of_band,
          week_started_at: date.beginning_of_week,
          unit_id: 3213,
        )
      end

      specify do
        expect(weekly_log.has_out_of_band_pair?).to eq false
      end
    end
  end
end
