class FilterForm
  include ActiveModel::Model

  attr_accessor :status, :program_id, :current_account, :page, :sort_column, :sort_direction

  def program
    @program ||= current_account.program || selected_program
  end

  def bounds
    @bounds ||= program.projects.bounds
  end

  def param_name
    'filters'
  end

  def to_query_params
    { param_name => attributes }
  end

  def to_query_params_for_pagination
    { param_name => attributes.except(:page) }
  end

  def self.policy_class
    FilterByProgramPolicy
  end

  private

  def selected_program
    Program.find_by(id: program_id) || NilProgram.new
  end

  def attributes
    {
      program_id: program_id,
      status: status,
      page: page,
      sort_column: sort_column,
      sort_direction: sort_direction
    }
  end
end
