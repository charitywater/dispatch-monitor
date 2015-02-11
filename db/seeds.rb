# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

partner = Partner.find_or_create_by(name: 'Pivotal Labs')
country = Country.find_or_create_by(name: 'United States of America')
program = Program.find_or_create_by(partner_id: partner.id, country_id: country.id)
project = Project.find_or_initialize_by(wazi_id: -625).tap do |p|
  p.update(
    program_id: program.id,
    deployment_code: 'TE.STS.Q2.14.001.001',
    grant_deployment_code: 'TE.STS.Q2.14.001',
    region: 'California',
    district: 'San Francisco',
    community_name: 'San Francisco',
    site_name: 'Lime Labs',
    completion_date: DateTime.new(2014, 06, 10, 15, 0, 0),
    latitude: 37.764795,
    longitude: -122.394530,
    beneficiaries: 825863,
    location_type: 'City and County',
    inventory_type: 'Sutro Bathhouse',
    quarter: 'Q2.2014',
  )
end

Activity.find_or_create_by(
  project_id: project.id,
  happened_at: DateTime.new(2014, 06, 10, 15, 0, 0),
  activity_type: Activity.activity_types[:completed_construction]
)

account = Account.find_or_initialize_by(email: 'saqib.bedi@charitywater.org')
if account.new_record?
  account.update(
    name: 'Saqib Bedi',
    password: 'password123',
    timezone: 'America/New_York',
  )
end
