module Import
  class MaintenanceReportMailer < Mailer
    default subject: 'Your Maintenance Report import has finished'

    def results(import_results)
      import_results = import_results.with_indifferent_access
      recipient = Account.find(import_results[:recipient_id])
      import_results[:results].map! do |result|
        r = result.with_indifferent_access
        r.reverse_merge!(complete: [], incomplete: [], invalid: [], inactive: [])
      end

      import_results[:recipient] = recipient

      mail to: recipient.name_and_email do |format|
        format.text { render template: template, locals: import_results }
      end
    end

    def template
      'import/maintenance_report_mailer/results'
    end
  end
end
