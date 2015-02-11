class ProjectMap
  attr_reader :filter_form, :selected_project

  def initialize(filter_form, selected_project = nil)
    @filter_form = filter_form
    @selected_project = selected_project
  end
end
