namespace :wazi do
  desc 'Import PIMS projects (grant 144)'
  task :import_pims_144 => :environment do |t, args|
    # set up any variables
    partner = Partner.where(name: "Relief Society of Tigray").first
    program_id = Program.where(partner: partner).first.id

    # import the file into array
    wazi_144 = CSV.read("#{Rails.root}/lib/tasks/wazi_144.csv", :encoding => 'windows-1251:utf-8')

    # remove first row
    #["id", "deployment_code", "community_name", "population", "cost_estimate", "plaque_text", "location_type_id", "project_type_id", "status_id", "grant_id", "grant_program_id", "region", "rehab", "revenue_category", "package_id", "fluxx_regrant_id", "possible_location_types", "state", "district", "sub_district", "system_name", "water_point_name", "latitude", "longitude"]

    wazi_144.shift

    # for each row in the array, create new project
    wazi_144.each do |row|

      # replacing the "new" id in the spreadsheet with a random number since these projects dont exist yet
      # we need to replace this with the real wazi_id on completion
      if row[0] == 'new'
        wazi_id = "999#{rand(0..999999)}"
      else
        wazi_id = row[0]
      end

      # check if deploy code exists (it shouldn't), if it does then skip the project and print the deploy code
      if Project.where(deployment_code: row[1]).exists?
        p "found #{row[1]}, skipping"
      else
      # create the project
        p "creating #{row[1]}"
        Project.create!(
          "deployment_code" => row[1],
          "wazi_id" => wazi_id,
          "grant_id" => row[9],
          "quarter" => '',
          "inventory_group" => '',
          "community_name" => row[2],
          "review_status_name" => '',
          "package_id" => row[14],
          "region" => row[11],
          "possible_location_types" => row[16],
          "inventory_type" => '',
          "inventory_cost" => '',
          "cost_actual" => '',
          "beneficiaries" => row[3],
          "funding_source" => '',
          "revenue_category" => row[13],
          "revenue_category_display_label" => '',
          "rehab" => row[12],
          "latitude" => row[22],
          "longitude" => row[23],
          "resubmission_notes" => '',
          "location_type" => '',
          "image_url" => '',
          "plaque_text" => row[4],
          "package_name" => '',
          "grant_title" => '',
          "grant_deployment_code" => '',
          "completion_date" => '',
          "is_ready_to_fund" => '',
          "status" => "unknown",
          "program_id" => program_id,
          "district" => row[18],
          "site_name" => '',
          "contact_name" => '',
          "contact_email" => '',
          "contact_phone_numbers" => '',
          "state" => row[17],
          "sub_district" => row[19],
          "system_name" => row[20],
          "water_point_name" => row[21]
        )
      end
    end
  end

  task :import_pims_148 => :environment do
    # set up any variables
    partner = Partner.where(name: "Relief Society of Tigray").first
    program_id = Program.where(partner: partner).first.id

    # import the file into array
    wazi_148 = CSV.read("#{Rails.root}/lib/tasks/wazi_148.csv", :encoding => 'windows-1251:utf-8')

    # remove first row
    # ["id", "deployment_code", "community_name", "population", "population_override", "latitude", "longitude", [6]"cost_estimate", "plaque_text", "location_type_id", "project_type_id", "sub_project_type_id", "status_id", [12]"grant_id", "grant_program_id", "d2p_batch_id", "mycw", "region", "funding_source", "rehab", "revenue_category",[20] "package_id", "fluxx_id", "fluxx_regrant_id", "possible_location_types", "review_status_name", [25]"resubmission_notes", "state", "district", "sub_district", "system_name", "water_point_name", "latitude_display", "longitude_display"] [33]

    wazi_148.shift

    # for each row in the array, create new project
    wazi_148.each do |row|

      # replacing the "new" id in the spreadsheet with a random number since these projects dont exist yet
      # we need to replace this with the real wazi_id on completion
      if row[0] == 'new'
        wazi_id = "999#{rand(0..999999)}"
      else
        wazi_id = row[0]
      end

      # check if deploy code exists (it shouldn't), if it does then skip the project and print the deploy code
      if Project.where(deployment_code: row[1]).exists?
        p "found #{row[1]}, skipping"
      else
      # create the project
        p "creating #{row[1]}"
        Project.create!(
          "deployment_code" => row[1],
          "wazi_id" => wazi_id,
          "grant_id" => row[13],
          "quarter" => '',
          "inventory_group" => '',
          "community_name" => row[2],
          "review_status_name" => row[25],
          "package_id" => row[21],
          "region" => row[17],
          "possible_location_types" => row[24],
          "inventory_type" => '',
          "inventory_cost" => '',
          "cost_actual" => '',
          "beneficiaries" => row[3],
          "funding_source" => row[18],
          "revenue_category" => row[20],
          "revenue_category_display_label" => '',
          "rehab" => row[19],
          "latitude" => row[5],
          "longitude" => row[6],
          "resubmission_notes" => row[26],
          "location_type" => '',
          "image_url" => '',
          "plaque_text" => row[8],
          "package_name" => '',
          "grant_title" => '',
          "grant_deployment_code" => '',
          "completion_date" => '',
          "is_ready_to_fund" => '',
          "status" => "unknown",
          "program_id" => program_id,
          "district" => row[28],
          "site_name" => '',
          "contact_name" => '',
          "contact_email" => '',
          "contact_phone_numbers" => '',
          "state" => row[27],
          "sub_district" => row[29],
          "system_name" => row[30],
          "water_point_name" => row[31]
        )
      end
    end
  end

  task :import_pims_156 => :environment do
    # set up any variables
    partner = Partner.where(name: "Relief Society of Tigray").first
    program_id = Program.where(partner: partner).first.id

    # import the file into array
    wazi_156 = CSV.read("#{Rails.root}/lib/tasks/wazi_156.csv", :encoding => 'windows-1251:utf-8')

    # remove first row
    # ["id", "deployment_code", "community_name", "population", "population_override", "latitude", "longitude", [6] "cost_estimate", "cost_actual", "other_funding_amt", "other_funding_donation_count", "completion_date", [11]"partner_project_code", "plaque_text", "project_specific_field_notes", "internal_notes", "image_url", [16]"location_type_id", "project_type_id", "sub_project_type_id", "status_id", "grant_id", "grant_program_id", [22]"d2p_batch_id", "mycw", "region", "funding_source", "rehab", "revenue_category", "package_id", "fluxx_id", [30]"fluxx_regrant_id", "possible_location_types", "review_status_name", "resubmission_notes", "state", "district", [36]"sub_district", "system_name", "water_point_name", "latitude_display", "longitude_display"] [41]

    wazi_156.shift

    # for each row in the array, create new project
    wazi_156.each do |row|

      # replacing the "new" id in the spreadsheet with a random number since these projects dont exist yet
      # we need to replace this with the real wazi_id on completion
      if row[0] == 'new'
        wazi_id = "999#{rand(0..999999)}"
      else
        wazi_id = row[0]
      end

      # check if deploy code exists (it shouldn't), if it does then skip the project and print the deploy code
      if Project.where(deployment_code: row[1]).exists?
        p "found #{row[1]}, skipping"
      else
      # create the project
        p "creating #{row[1]}"
        Project.create!(
          "deployment_code" => row[1],
          "wazi_id" => wazi_id,
          "grant_id" => row[21],
          "quarter" => '',
          "inventory_group" => '',
          "community_name" => row[2],
          "review_status_name" => row[33],
          "package_id" => row[29],
          "region" => row[25],
          "possible_location_types" => row[32],
          "inventory_type" => '',
          "inventory_cost" => '',
          "cost_actual" => '',
          "beneficiaries" => row[3],
          "funding_source" => row[26],
          "revenue_category" => row[28],
          "revenue_category_display_label" => '',
          "rehab" => row[27],
          "latitude" => row[5],
          "longitude" => row[6],
          "resubmission_notes" => row[34],
          "location_type" => '',
          "image_url" => '',
          "plaque_text" => row[13],
          "package_name" => '',
          "grant_title" => '',
          "grant_deployment_code" => '',
          "completion_date" => '',
          "is_ready_to_fund" => '',
          "status" => "unknown",
          "program_id" => program_id,
          "district" => row[36],
          "site_name" => '',
          "contact_name" => '',
          "contact_email" => '',
          "contact_phone_numbers" => '',
          "state" => row[35],
          "sub_district" => row[37],
          "system_name" => row[38],
          "water_point_name" => row[39]
        )
      end
    end
  end

  task :import_pims_162 => :environment do
    # set up any variables
    partner = Partner.where(name: "Relief Society of Tigray").first
    program_id = Program.where(partner: partner).first.id

    # import the file into array
    wazi_162 = CSV.read("#{Rails.root}/lib/tasks/wazi_162.csv", :encoding => 'windows-1251:utf-8')

    # remove first row
    # ["id", "deployment_code", "community_name", "population", "population_override", "latitude", "longitude", [6]"cost_estimate", "cost_actual", "other_funding_amt", "other_funding_donation_count", "completion_date", [11]"partner_project_code", "plaque_text", "project_specific_field_notes", "internal_notes", "image_url", [16]"location_type_id", "project_type_id", "sub_project_type_id", "status_id", "grant_id", "grant_program_id", [22]"d2p_batch_id", "mycw", "region", "funding_source", "rehab", "revenue_category", "package_id", "fluxx_id", [30]"fluxx_regrant_id", "possible_location_types", "review_status_name", "resubmission_notes", "state", "district", [36]"sub_district", "system_name", "water_point_name"] [39]

    wazi_162.shift

    # for each row in the array, create new project
    wazi_162.each do |row|

      # replacing the "new" id in the spreadsheet with a random number since these projects dont exist yet
      # we need to replace this with the real wazi_id on completion
      if row[0] == 'new'
        wazi_id = "999#{rand(0..999999)}"
      else
        wazi_id = row[0]
      end

      # check if deploy code exists (it shouldn't), if it does then skip the project and print the deploy code
      if Project.where(deployment_code: row[1]).exists?
        p "found #{row[1]}, skipping"
      else
      # create the project
        p "creating #{row[1]}"
        Project.create!(
          "deployment_code" => row[1],
          "wazi_id" => wazi_id,
          "grant_id" => row[21],
          "quarter" => '',
          "inventory_group" => '',
          "community_name" => row[2],
          "review_status_name" => row[33],
          "package_id" => row[29],
          "region" => row[25],
          "possible_location_types" => row[32],
          "inventory_type" => '',
          "inventory_cost" => '',
          "cost_actual" => '',
          "beneficiaries" => row[3],
          "funding_source" => row[26],
          "revenue_category" => row[28],
          "revenue_category_display_label" => '',
          "rehab" => row[27],
          "latitude" => row[5],
          "longitude" => row[6],
          "resubmission_notes" => row[34],
          "location_type" => '',
          "image_url" => '',
          "plaque_text" => row[13],
          "package_name" => '',
          "grant_title" => '',
          "grant_deployment_code" => '',
          "completion_date" => '',
          "is_ready_to_fund" => '',
          "status" => "unknown",
          "program_id" => program_id,
          "district" => row[36],
          "site_name" => '',
          "contact_name" => '',
          "contact_email" => '',
          "contact_phone_numbers" => '',
          "state" => row[35],
          "sub_district" => row[37],
          "system_name" => row[38],
          "water_point_name" => row[39]
        )
      end
    end
  end

  task :import_all => :environment do
    # delete all projects from 144, 148, 156, 162
    projects_144 = Project.where("deployment_code LIKE '%ET.GOH.Q2.13.144%'")
    projects_144.delete_all
    projects_148 = Project.where("deployment_code LIKE '%ET.GOH.Q3.13.148%'")
    projects_148.delete_all
    projects_156 = Project.where("deployment_code LIKE '%ET.GOH.Q4.13.156%'")
    projects_156.delete_all
    projects_162 = Project.where("deployment_code LIKE '%ET.RST.Q2.14.162%'")
    projects_162.delete_all

    # re-import all
    Rake::Task[ 'wazi:import_pims_144' ].invoke
    Rake::Task[ 'wazi:import_pims_148' ].invoke
    Rake::Task[ 'wazi:import_pims_156' ].invoke
    Rake::Task[ 'wazi:import_pims_162' ].invoke
  end
end
