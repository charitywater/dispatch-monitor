require 'spec_helper'

feature 'List vehicles' do
  scenario 'Viewing a list of vehicles', :js do
    Given 'There are many vehicles'
    And 'I am logged in as an admin'
    When 'I view the list of vehicles'
    Then 'I see the vehicles'
  end

  scenario 'Viewing the last transmission', :js do
    Given 'There is a vehicle with a gps transmission'
    And 'I am logged in as an admin'
    When 'I view the list of vehicles'
    Then 'I see the latest transmission'
  end

  scenario 'Viewing the program', :js do
    Given 'There is a vehicle with a program'
    And 'I am logged in as an admin'
    When 'I view the list of vehicles'
    Then 'I see the associated program'
  end

  scenario 'Viewing no associated program', :js do
    Given 'There is a vehicle without a program'
    And 'I am logged in as an admin'
    When 'I view the list of vehicles'
    Then 'I see the lack of associated program'
  end

  def there_are_many_vehicles
    create(:vehicle, esn: "0-1250133", vehicle_type: "bike")
    create(:vehicle, esn: "0-1247106", vehicle_type: "bike")
    create(:vehicle, esn: "0-1248964", vehicle_type: "bike")
    create(:vehicle, esn: "0-1227975", vehicle_type: "bike")
    create(:vehicle, esn: "0-1227980", vehicle_type: "bike")
    create(:vehicle, esn: "0-1248779", vehicle_type: "bike")
    create(:vehicle, esn: "0-1227634", vehicle_type: "bike")
    create(:vehicle, esn: "0-1227749", vehicle_type: "rig")
  end

  def there_is_a_vehicle_with_a_gps_transmission
    vehicle = create(:vehicle, esn: "0-1247106", vehicle_type: "bike")
    create(
      :gps_message,
      esn: "0-1247106",
      transmitted_at: DateTime.new(2014,1,1),
      vehicle: vehicle,
      latitude: "1234",
      longitude: "124"
    )
    create(
      :gps_message,
      esn: "0-1247106",
      transmitted_at: DateTime.new(2014,2,1),
      vehicle: vehicle,
      latitude: "23234",
      longitude: "34324234"
    )
    create(
      :gps_message,
      esn: "0-1247106",
      transmitted_at: DateTime.new(2014,3,1),
      vehicle: vehicle,
      latitude: "13.537452",
      longitude: "39.508295"
    )
  end

  def there_is_a_vehicle_with_a_program
    rest = create(:partner, name: "Relief Society of Tigray")
    ethiopia = create(:country, name: "Ethiopia")
    rest_ethiopia = create(:program, country: ethiopia, partner: rest)
    vehicle = create(:vehicle, esn: "0-1247106", vehicle_type: "bike", program: rest_ethiopia)
    create(
      :gps_message,
      esn: "0-1247106",
      transmitted_at: DateTime.new(2014,3,1),
      vehicle: vehicle,
      latitude: "13.537452",
      longitude: "39.508295"
    )
  end

  def there_is_a_vehicle_without_a_program
    vehicle = create(:vehicle, esn: "0-1247106", vehicle_type: "bike", program: nil)
    create(
      :gps_message,
      esn: "0-1247106",
      transmitted_at: DateTime.new(2014,3,1),
      vehicle: vehicle,
      latitude: "13.537452",
      longitude: "39.508295"
    )
  end

  def i_view_the_list_of_vehicles
    visit root_path
    click_link 'Vehicles'
  end

  def i_see_the_vehicles
    within 'table' do
      expect(page).to have_content(/ESN/i)
      expect(page).to have_content(/Vehicle Type/i)
      expect(page).to have_content(/0-1250133/i)
      expect(page).not_to have_content(/0-1227749/i)
    end
  end

  def i_see_the_latest_transmission
    expect(page).to have_content(/Latest Transmission Time/i)
    expect(page).to have_content(/2014-03-01 00:00:00 UTC/i)
    expect(page).to have_content(/Latitude/i)
    expect(page).to have_content(/13.537452/i)
    expect(page).to have_content(/Longitude/i)
    expect(page).to have_content(/39.508295/i)
  end

  def i_see_the_associated_program
    expect(page).to have_content(/Latest Transmission Time/i)
    expect(page).to have_content(/2014-03-01 00:00:00 UTC/i)
    expect(page).to have_content(/Latitude/i)
    expect(page).to have_content(/13.537452/i)
    expect(page).to have_content(/Longitude/i)
    expect(page).to have_content(/39.508295/i)
    expect(page).to have_content(/Program/i)
    expect(page).to have_content(/Relief Society of Tigray - Ethiopia/i)
  end

  def i_see_the_lack_of_associated_program
    expect(page).to have_content(/Latest Transmission Time/i)
    expect(page).to have_content(/2014-03-01 00:00:00 UTC/i)
    expect(page).to have_content(/Latitude/i)
    expect(page).to have_content(/13.537452/i)
    expect(page).to have_content(/Longitude/i)
    expect(page).to have_content(/39.508295/i)
    expect(page).to have_content(/Program/i)
    expect(page).to have_content(/N\/A/i)
  end
end
