class TicketPolicy < Struct.new(:account, :ticket)
  def create?
    (manage? || account.program == ticket.program) && !account.viewer?
  end

  def show?
    manage? || account.program == ticket.program || (account.viewer? && account.program == nil)
  end

  def update?
    (manage? || account.program == ticket.program) && !account.viewer?
  end

  def manage?
    account.admin?
  end
  alias_method :destroy?, :manage?
end
