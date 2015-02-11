require 'spec_helper'

module Wazi
  describe Client, :integration, :vcr do
    let(:client) { Client.new }

    context 'valid request' do
      it 'returns the projects grouped by deployment code' do
        deployment_codes = [
          'ET.GOH.Q4.09.048.123',
          'ET.GOH.Q4.09.048.124',
          'ET.GOH.Q4.09.048.199'
        ]
        projects = deployment_codes.map { |d| client.projects(deployment_code: d) }.flatten

        expect(projects.map { |p| p['deployment_code'] }).to match_array deployment_codes
      end

      it 'returns the fields for a project' do
        deployment_code = 'ET.GOH.Q4.09.048.123'
        project = client.projects(deployment_code: deployment_code).first

        keys = %w[
          id grant_id quarter inventory_group deployment_code community_name
          review_status_name package_id region possible_location_types
          inventory_type inventory_cost cost_actual beneficiaries funding_source
          revenue_category revenue_category_display_label rehab latitude
          longitude resubmission_notes location_type image_url plaque_text
          package_name grant_title grant_deployment_code completion_date
          is_ready_to_fund
        ]

        #  district state sub_district sub_project_type sub_project_type_id system_name water_point_name
        expect(project.keys).to match_array keys
      end
    end

    context 'invalid request' do
      specify do
        expect(client.projects(deployment_code: 'bogus')).to be_nil
      end
    end
  end
end
