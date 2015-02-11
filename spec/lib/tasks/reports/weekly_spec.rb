require 'spec_helper'

describe 'rake reports:admin_weekly' do
  before do
    Timecop.freeze

    allow(RemoteMonitoring::JobQueue).to receive(:enqueue)
    allow(Time).to receive(:now) { Time.new(2015,1,3) } # on a Saturday

    Rake::Task['reports:admin_weekly'].reenable
  end

  after do
    Timecop.return
  end

  it 'enqueues the weekly report job' do
    Rake::Task['reports:admin_weekly'].invoke

    expect(RemoteMonitoring::JobQueue).to have_received(:enqueue).with(
      Report::WeeklyReport::AdminWeeklyReportJob,
    )
  end
end

describe 'rake reports:program_manager_weekly' do
  before do
    Timecop.freeze
    
    allow(RemoteMonitoring::JobQueue).to receive(:enqueue)
    allow(Time).to receive(:now) { Time.new(2015,1,3) } # on a Saturday

    Rake::Task['reports:program_manager_weekly'].reenable
  end

  after do
    Timecop.return
  end

  it 'enqueues the weekly report job' do
    Rake::Task['reports:program_manager_weekly'].invoke

    expect(RemoteMonitoring::JobQueue).to have_received(:enqueue).with(
      Report::WeeklyReport::ProgramManagerWeeklyReportJob,
    )
  end
end