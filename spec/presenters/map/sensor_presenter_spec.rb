require 'spec_helper'

module Map
  describe Map::SensorPresenter do
    let(:project) { build(:project, id: 6) }
    let!(:sensor) { build(:sensor, id: 5, project: project) }
    let(:presenter) { SensorPresenter.new(sensor) }

    describe '#as_json' do
      specify do
        json = presenter.as_json
        expect(json).to include(*%i[
          id project_id graph_data
        ])
        expect(json[:id]).to eq 5
        expect(json[:project_id]).to eq 6
      end
    end

    describe '#graph_data' do
      let(:weekly_logs) { double(:weekly_logs) }
      let(:recent_weekly_logs) { double(:recent_weekly_logs) }
      let(:ordered_recent_weekly_logs) { [ WeeklyLog.new ] }

      before do
        Timecop.travel DateTime.rfc2822('Tue, 1 Jul 2014 12:00:00 +0000')

        create(:weekly_log, sensor: sensor, received_at: Time.zone.now, liters: [1, 2, 3, 4, 5, 6, 7])
        create(:weekly_log, sensor: sensor, received_at: 3.weeks.ago, liters: [31, 32, 33, 34, 35, 36, 37])
        create(:weekly_log, sensor: sensor, received_at: 4.weeks.ago, liters: [41, 42, 43, 44, 45, 46, 47])
        create(:weekly_log, sensor: sensor, received_at: 5.weeks.ago, liters: [0, 0, 0, 0, 0, 0, 9991])
        create(:weekly_log, received_at: 2.weeks.ago, liters: [9992, 0, 0, 0, 0, 0, 0])
        create(:weekly_log, :out_of_band, sensor: sensor, received_at: 2.weeks.ago, liters: [9993, 0, 0, 0, 0, 0, 0])
      end

      after do
        Timecop.return
      end

      it 'returns the weekly logs as json' do
        expect(presenter.graph_data).to eq [
          { date: DateTime.new(2014, 6,  4, 0, 0, 0, '+0'), liters: 44 },
          { date: DateTime.new(2014, 6,  5, 0, 0, 0, '+0'), liters: 45 },
          { date: DateTime.new(2014, 6,  6, 0, 0, 0, '+0'), liters: 46 },
          { date: DateTime.new(2014, 6,  7, 0, 0, 0, '+0'), liters: 47 },

          { date: DateTime.new(2014, 6,  8, 0, 0, 0, '+0'), liters: 31 },
          { date: DateTime.new(2014, 6,  9, 0, 0, 0, '+0'), liters: 32 },
          { date: DateTime.new(2014, 6, 10, 0, 0, 0, '+0'), liters: 33 },
          { date: DateTime.new(2014, 6, 11, 0, 0, 0, '+0'), liters: 34 },
          { date: DateTime.new(2014, 6, 12, 0, 0, 0, '+0'), liters: 35 },
          { date: DateTime.new(2014, 6, 13, 0, 0, 0, '+0'), liters: 36 },
          { date: DateTime.new(2014, 6, 14, 0, 0, 0, '+0'), liters: 37 },

          { date: DateTime.new(2014, 6, 15, 0, 0, 0, '+0'), liters: 0 },
          { date: DateTime.new(2014, 6, 16, 0, 0, 0, '+0'), liters: 0 },
          { date: DateTime.new(2014, 6, 17, 0, 0, 0, '+0'), liters: 0 },
          { date: DateTime.new(2014, 6, 18, 0, 0, 0, '+0'), liters: 0 },
          { date: DateTime.new(2014, 6, 19, 0, 0, 0, '+0'), liters: 0 },
          { date: DateTime.new(2014, 6, 20, 0, 0, 0, '+0'), liters: 0 },
          { date: DateTime.new(2014, 6, 21, 0, 0, 0, '+0'), liters: 0 },

          { date: DateTime.new(2014, 6, 22, 0, 0, 0, '+0'), liters: 0 },
          { date: DateTime.new(2014, 6, 23, 0, 0, 0, '+0'), liters: 0 },
          { date: DateTime.new(2014, 6, 24, 0, 0, 0, '+0'), liters: 0 },
          { date: DateTime.new(2014, 6, 25, 0, 0, 0, '+0'), liters: 0 },
          { date: DateTime.new(2014, 6, 26, 0, 0, 0, '+0'), liters: 0 },
          { date: DateTime.new(2014, 6, 27, 0, 0, 0, '+0'), liters: 0 },
          { date: DateTime.new(2014, 6, 28, 0, 0, 0, '+0'), liters: 0 },

          { date: DateTime.new(2014, 6, 29, 0, 0, 0, '+0'), liters: 1 },
          { date: DateTime.new(2014, 6, 30, 0, 0, 0, '+0'), liters: 2 },
          { date: DateTime.new(2014, 7,  1, 0, 0, 0, '+0'), liters: 3 },
        ]
      end
    end
  end
end
