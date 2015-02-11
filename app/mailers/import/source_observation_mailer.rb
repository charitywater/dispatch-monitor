module Import
  class SourceObservationMailer < Mailer
    default subject: 'Your Source Observation import has finished'

    def results(import_results)
      import_results = import_results.with_indifferent_access

      recipient = Account.find(import_results[:recipient_id])

      import_results[:results].map! do |result|
        r = result.with_indifferent_access
        r.reverse_merge!(created: [], updated: [], invalid: [])
        r.merge(additional_data(r))
      end

      import_results[:recipient] = recipient

      mail to: recipient.name_and_email do |format|
        format.text { render template: template, locals: import_results }
      end
    end

    private

    def template
      'import/source_observation_mailer/results'
    end

    def additional_data(result)
      fs_response_ids = (result[:created] + result[:updated])
        .map { |f| f[:fs_response_id] }

      {
        needs_maintenance_deployment_codes:
          needs_maintenance_deployment_codes(fs_response_ids),
        needs_visit_count:
          needs_visit_count(fs_response_ids),
      }
    end

    def needs_maintenance_deployment_codes(fs_response_ids)
      projects(fs_response_ids)
        .needs_maintenance
        .pluck(:deployment_code)
    end

    def needs_visit_count(fs_response_ids)
      projects(fs_response_ids)
        .needs_visit
        .count
    end

    def projects(fs_response_ids)
      ::Project
        .joins(:survey_responses)
        .where(survey_responses: { fs_response_id: fs_response_ids })
        .order(:deployment_code)
        .distinct
    end
  end
end
