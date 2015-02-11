module Import
  class ProjectMailer < Mailer
    default subject: 'Your project import has finished'

    def results(import_results)
      import_results = import_results.with_indifferent_access

      result = import_results[:results].with_indifferent_access
      result.reverse_merge!(created: [], updated: [], invalid: [])

      recipient = Account.find(import_results[:recipient_id])
      result[:recipient] = recipient

      mail to: recipient.name_and_email do |format|
        format.text { render template: template, locals: result }
      end
    end

    def template
      'import/project_mailer/results'
    end
  end
end
