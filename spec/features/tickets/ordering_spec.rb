require 'spec_helper'

feature 'Ordering of tickets' do
  scenario 'Admin views tickets in the right order' do
    turn_off_pagination do
      Given 'There are tickets'
      And 'I am logged in as an admin'
      When 'I am viewing the list of tickets'
      Then 'I see the tickets in order'
    end
  end

  before do
    Timecop.travel DateTime.new(2014)
  end

  after do
    Timecop.return
  end

  def there_are_tickets
    project_1 = create(:project, community_name: 'Project 1')
    project_3 = create(:project, community_name: 'Project 3')
    project_2 = create(:project, community_name: 'Project 2')
    project_4 = create(:project, community_name: 'Project 4')
    project_6 = create(:project, community_name: 'Project 6')
    project_5 = create(:project, community_name: 'Project 5')
    project_7 = create(:project, community_name: 'Project 7')

    create(:ticket, :complete, id: 1,     project: project_7, started_at: DateTime.new(1850), due_at: DateTime.new(1900), completed_at: DateTime.new(1999))
    create(:ticket, :complete, id: 2,     project: project_6, started_at: DateTime.new(1850), due_at: DateTime.new(1890), completed_at: DateTime.new(2000))
    create(:ticket, :overdue, id: 3,      project: project_1, started_at: DateTime.new(1850), due_at: DateTime.new(1900))
    create(:ticket, :complete, id: 4,     project: project_5, started_at: DateTime.new(1850), due_at: DateTime.new(1899), completed_at: DateTime.new(2001))
    create(:ticket, :in_progress, id: 5,  project: project_3,                                 due_at: 5.days.from_now)
    create(:ticket, :overdue, id: 6,      project: project_2, started_at: DateTime.new(1850), due_at: DateTime.new(1902))
    create(:ticket, :in_progress, id: 7,  project: project_4,                                 due_at: 8.days.from_now)
  end

  def i_am_viewing_the_list_of_tickets
    click_on 'Tickets'
    expect(page).to have_content 'Tickets'
  end

  def i_see_the_tickets_in_order
    expect(page).to have_content(/
      Project\s7.*?Complete.*?1999.*?
      Project\s6.*?Complete.*?2000.*?
      Project\s1.*?Overdue.*?1900.*?
      Project\s5.*?Complete.*?2001.*?
      Project\s3.*?In\sProgress.*?2014-01-06.*?
      Project\s2.*?Overdue.*?1902.*?
      Project\s4.*?In\sProgress.*?2014-01-09.*?
    /mx)
  end
end
