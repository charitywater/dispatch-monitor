require 'spec_helper'

describe 'rake survey_response_import:maintenance_report' do
  before do
    allow(RemoteMonitoring::JobQueue).to receive(:enqueue)

    Rake::Task['survey_response_import:maintenance_report'].reenable
  end

  it 'enqueues the bulk survey job with the maintenance report v1 survey by default' do
    Rake::Task['survey_response_import:maintenance_report'].invoke

    expect(RemoteMonitoring::JobQueue).to have_received(:enqueue).with(
      Import::MaintenanceReportsJob,
      %w(maintenance_report_v02 test_maintenance_report_v02)
    )
  end

  it 'enqueues the bulk survey job with the survey_id argument' do
    Rake::Task['survey_response_import:maintenance_report'].invoke('type-1', 'type-2')

    expect(RemoteMonitoring::JobQueue).to have_received(:enqueue).with(
      Import::MaintenanceReportsJob,
      ['type-1', 'type-2']
    )
  end
end
