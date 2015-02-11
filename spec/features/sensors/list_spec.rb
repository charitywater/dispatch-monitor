require 'spec_helper'

feature 'List sensors' do
  scenario 'Viewing a list of sensors', :js do
    Given 'There are many sensors'
    And 'I am logged in as an admin'
    When 'I am viewing the list of sensors'
    Then 'I can navigate between pages of sensors'
  end

  scenario 'Associating a sensor with a project' do
    Given 'There is a project'
    And 'I am logged in as an admin'
    When 'I associate a sensor with a project'
    Then 'I can see the new sensor in the list'
  end

  scenario 'Deleting a sensor', :js do
    Given 'There is a sensor associated with a project'
    And 'I am logged in as an admin'
    When 'I delete the sensor'
    Then 'I no longer see the sensor in the list'
  end

  def there_are_many_sensors
    project = create(:project, deployment_code: 'AA.AAA.Q1.11.111.111', community_name: 'Fancy Community')
    sensor = create(:sensor, device_id: -2, imei: "013949004634708", project: project)
    create(
      :weekly_log,
      sensor: sensor,
      week: 10,
      liters: [410, 406],
    )

    create_list(:sensor, 4)

    project = create(:project, deployment_code: 'BB.BBB.Q1.11.111.111', community_name: 'Dapper Community')
    sensor = create(:sensor, device_id: 54321, imei: "613949004634709", project: project)
    create(
      :weekly_log,
      sensor: sensor,
      week: 6,
      liters: [320, 400],
    )
  end

  def i_am_viewing_the_list_of_sensors
    visit root_path
    click_link 'Sensors'
    
    expect(page).to have_content(/IMEI/i)
    expect(page).to have_content(/Deployment Code/i)
    expect(page).to have_content(/Community/i)
    expect(page).to have_content(/Uptime/i)
    expect(page).to have_content(/Daily Average/i)
    expect(page).to have_content(/Actions/i)
  end

  def i_can_navigate_between_pages_of_sensors
    within 'table' do
      expect(page).to have_content 'AA.AAA.Q1.11.111.111'
      expect(page).to have_content '10'
      expect(page).to have_content(/408(?!\.)/)
      expect(page).not_to have_content 'BB.BBB.Q1.11.111.111'
    end
    click_first_link 'Next'

    within 'table' do
      expect(page).not_to have_content 'AA.AAA.Q1.11.111.111'
      expect(page).to have_content 'BB.BBB.Q1.11.111.111'
      expect(page).to have_content '6'
      expect(page).to have_content(/360(?!\.)/)
    end

    click_first_link 'First'

    within 'table' do
      expect(page).to have_content 'AA.AAA.Q1.11.111.111'
      expect(page).not_to have_content 'BB.BBB.Q1.11.111.111'
    end
  end

  def there_is_a_project
    create(:project, deployment_code: 'AA.AAA.Q1.11.111.111', community_name: 'Fancy Community')
  end

  def i_associate_a_sensor_with_a_project
    visit root_path
    click_link 'Sensors'

    click_link '+ Sensor'
    expect(page).to have_field 'Deployment Code'
    expect(page).to have_field 'Imei'


    fill_in 'Deployment Code', with: 'AA.AAA.Q1.11.111.111'
    fill_in 'Imei', with: '013949004634710'

    click_button 'Add'
  end

  def i_can_see_the_new_sensor_in_the_list
    expect(page).to have_content 'Actions'

    within 'table' do
      expect(page).to have_content 'AA.AAA.Q1.11.111.111'
      expect(page).to have_content '013949004634710'
    end
  end

  def there_is_a_sensor_associated_with_a_project
    project = create(:project, deployment_code: 'AA.AAA.Q1.11.111.111')
    create(:sensor, device_id: 1, imei: "013949004634711", project: project)

    project = create(:project, deployment_code: 'AA.AAA.Q2.11.111.111')
    create(:sensor, device_id: 2, imei: "013949004634712", project: project)
  end

  def i_delete_the_sensor
    visit root_path
    click_link 'Sensors'

    expect(page).to have_content 'AA.AAA.Q1.11.111.111'
    expect(page).to have_content 'AA.AAA.Q2.11.111.111'

    click_first_link 'Delete'
    accept_js_alert
  end

  def i_no_longer_see_the_sensor_in_the_list
    within 'table' do
      expect(page).not_to have_content 'AA.AAA.Q1.11.111.111'
      expect(page).to have_content 'AA.AAA.Q2.11.111.111'
    end
  end
end
