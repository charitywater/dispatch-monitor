class AccountPresenter < Presenter
  def role
    account.role.to_s.titleize
  end

  def program_name
    (account.program.present?) ? account.program.name : 'N/A'
  end

  def as_json(*_)
    {
      email: email
    }
  end

  private

  alias_method :account, :__getobj__
end
