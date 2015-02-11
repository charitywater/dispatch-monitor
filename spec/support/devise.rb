module LogIn
  def login_as(account)
    login(account.email, account.password)
    @current_account = account
  end

  def login(email, password)
    visit root_path

    expect(page).to have_content 'Email'
    expect(page).to have_content 'Password'
    expect(page).to have_button 'Login'

    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_button 'Login'

    expect(page).to have_content(/Logout/i)
  end

  def current_account
    @current_account
  end

  def i_am_logged_in_as_an_admin
    login_as current_admin
  end

  def i_am_logged_in_as_a_program_manager
    login_as program_manager
  end

  def i_am_logged_in_as_a_viewer
    login_as viewer
  end

  def i_am_logged_in_as_a_viewer_assigned_to_a_program
    login_as viewer_one_program
  end

  private

  def current_admin
    @current_admin ||= respond_to?(:admin) ? admin : create(:account, :admin, email: 'admin@example.com')
  end
end

module DeviseAliases
  def stub_logged_in(account = build(:account, :admin))
    allow(request.env['warden']).to receive(:authenticate!).and_return(account)
    allow(controller).to receive(:current_account).and_return(account)
  end
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, type: :controller
  config.include DeviseAliases, type: :controller
  config.include LogIn, type: :feature
end
