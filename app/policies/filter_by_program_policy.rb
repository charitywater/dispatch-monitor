class FilterByProgramPolicy < AdminPolicy
  def filter_by_program?
    manage? || (account.viewer? && account.program == nil)
  end
end
