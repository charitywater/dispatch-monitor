class AdminPolicy
  attr_reader :account

  def initialize(account, _ = nil)
    @account = account
  end

  def manage?
    account.admin?
  end
end
