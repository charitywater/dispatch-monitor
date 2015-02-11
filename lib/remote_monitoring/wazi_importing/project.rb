module RemoteMonitoring
  module WaziImporting
    class Project
      def import(wazi_project)
        project = ::Project.find_or_initialize_by(wazi_id: wazi_project['id'])

        params = project_params(wazi_project)
        if params.nil?
          nil
        else
          project.update(params)
          # Newly imported projects start with a 'Completed construction' activity
          create_activity_for(project)
          project
        end
      end

      private

      def project_params(wazi_project)
        params = params(wazi_project)

        if params['grant_title'].blank?
          nil
        else
          program = program(params['grant_title'])

          # Business logic: Updated/new projects have an :unknown status as
          # opposed to :flowing or :needs_maintenance
          params.merge(
            'program' => program,
            'status' => :unknown
          )
        end
      end

      def params(wazi_project)
        wazi_project.slice(*%w[
          beneficiaries community_name completion_date cost_actual
          deployment_code district funding_source grant_deployment_code
          grant_id grant_title image_url inventory_cost inventory_group
          inventory_type is_ready_to_fund latitude location_type longitude
          package_id package_name plaque_text possible_location_types quarter
          region rehab resubmission_notes revenue_category
          revenue_category_display_label review_status_name site_name state
          sub_district system_name water_point_name
        ])
      end

      def program(grant_title)
        country_name, partner_name = grant_title.split('-').map(&:strip)

        partner = Partner.find_or_create_by(name: map_name(partner_name))
        country = Country.find_or_create_by(name: country_name)

        Program.find_or_create_by(partner: partner, country: country)
      end

      def map_name(partner_name)
        Partner::NAME_MAP[partner_name] || partner_name
      end

      def create_activity_for(project)
        if project.completion_date
          Activity.completed_construction.find_or_create_by(
            project: project,
            happened_at: project.completion_date
          )
        end
      end
    end
  end
end
