namespace :reports do
  desc 'Send out the weekly report to admins'
  task admin_weekly: :environment do |t, args|
    if Time.zone.now.saturday?
      RemoteMonitoring::JobQueue.enqueue(Report::WeeklyReport::AdminWeeklyReportJob)
    end
  end

  desc 'Send out the weekly report to program managers'
  task program_manager_weekly: :environment do |t, args|
    if Time.zone.now.saturday?
      RemoteMonitoring::JobQueue.enqueue(Report::WeeklyReport::ProgramManagerWeeklyReportJob)
    end
  end
end