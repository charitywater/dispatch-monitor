class ProjectPolicy < Struct.new(:account, :project)
  def show?
    manage? || account.program == project.program || (account.viewer? && account.program == nil)
  end

  def manage?
    account.admin?
  end

  alias_method :update?, :manage?
  alias_method :destroy?, :manage?
end
