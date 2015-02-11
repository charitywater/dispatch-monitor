module Search
  class ProjectList < FilterableList
    attr_accessor :bounds

    def initialize(filter_form, bounds)
      @bounds = bounds
      super(filter_form)
    end

    def source
      filter_form.program.projects.within_bounds(*bounds)
    end

    def presenter
      Search::ProjectPresenter
    end
  end
end
