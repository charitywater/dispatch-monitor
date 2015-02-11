module Report
  class WeeklyReportMailer < Mailer
    default subject: 'Your Dispatch Monitor Weekly Report'

    def weekly_report_results(data)
      recipient = Account.find(data["recipient_id"])
      program = (data["results"]["program"].nil?) ? nil : Program.find(data["results"]["program"]["id"])
      week_start = Time.parse(data["results"]["week_start"])
      week_end = week_start + 7.days

      # get all status change activities for the week, sort by date, and remove any duplicates
      all_activities = (
        projects_that_were_fixed(program, week_start, week_end) + 
        projects_that_need_maintenance(program, week_start, week_end) +
        projects_that_need_visit(program, week_start, week_end)
      ).sort_by(&:happened_at).reverse
      all_activities = all_activities.uniq {|x| x.project}

      # break out activities into separate categories
      projects_that_were_fixed = all_activities.map {|x| x.project if x.data["status"] == 2}.compact
      projects_that_need_maintenance = all_activities.map {|x| x.project if x.data["status"] == 1}.compact
      projects_that_need_visit = all_activities.map {|x| x.project if x.data["status"] == 4}.compact

      flowing_deployment_codes = projects_that_were_fixed.map {|x| x.deployment_code}
      maintenance_deployment_codes = projects_that_need_maintenance.map {|x| x.deployment_code}
      visit_deployment_codes = projects_that_need_visit.map {|x| x.deployment_code}

      email_data = {
        :week_start => week_start.strftime("%m/%d/%Y"),
        :week_end => week_end.strftime("%m/%d/%Y"),
        :recipient => recipient,
        :program => program,
        :flowing_count => projects_that_were_fixed.count,
        :flowing_codes => flowing_deployment_codes,
        :maintenance_count => projects_that_need_maintenance.count,
        :maintenance_codes => maintenance_deployment_codes,
        :visit_count => projects_that_need_visit.count,
        :visit_codes => visit_deployment_codes
      }

      mail to: recipient.name_and_email do |format|
        format.html { render template: template, locals: email_data }
      end
    end

    private

    def template
      'report/weekly_report_mailer/send_weekly_report'
    end

    # refactor me
    def projects_that_were_fixed(program, start_date, end_date)
      activities = Activity::status_changed_to_flowing.where(:happened_at => start_date..end_date)

      if program.nil?
        activities
      else
        activities.map {|act| act if act.project.program == program}.compact
      end
    end

    def projects_that_need_maintenance(program, start_date, end_date)
      activities = Activity::status_changed_to_needs_maintenance.where(:happened_at => start_date..end_date)

      if program.nil?
        activities
      else
        activities.map {|act| act if act.project.program == program}.compact
      end
    end

    def projects_that_need_visit(program, start_date, end_date)
      activities = Activity::status_changed_to_needs_visit.where(:happened_at => start_date..end_date)

      if program.nil?
        activities
      else
        activities.map {|act| act if act.project.program == program}.compact
      end
    end
  end
end