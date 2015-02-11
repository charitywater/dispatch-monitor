require 'spec_helper'

feature 'Editing vehicle details' do
  scenario 'Admin edits', :js do
    Given 'There is a vehicle with a program'
    And 'I am logged in as an admin'
    When 'I edit the vehicle'
    Then 'I see the updated details'
  end

  def there_is_a_vehicle_with_a_program
    rest = create(:partner, name: "Relief Society of Tigray")
    ethiopia = create(:country, name: "Ethiopia")
    rest_ethiopia = create(:program, country: ethiopia, partner: rest)

    newah = create(:partner, name: "Nepal Water for Health")
    nepal = create(:country, name: "Nepal")
    newah_nepal = create(:program, country: nepal, partner: newah)

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

  def i_edit_the_vehicle
    i_view_the_vehicle_list

    expect(page).to have_content '0-1247106'

    click_on 'Edit'

    fill_in 'Vehicle type', with: 'bikez'

    click_on 'Update Vehicle'

    expect(page).not_to have_button 'Update Vehicle'
  end

  def i_see_the_updated_details
    expect(page).to have_content '0-1247106'
    expect(page).to have_content 'Bikez'

    click_on 'Edit'
    expect(page).not_to have_link 'Edit'

    expect(page).to have_field 'Esn', with: '0-1247106'
    expect(page).to have_field 'Vehicle type', with: 'bikez'
  end

  def i_view_the_vehicle_list
    click_on 'Vehicles'
    expect(page).to have_content '0-1247106'
  end
end
