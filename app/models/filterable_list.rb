class FilterableList
  attr_reader :filter_form

  def initialize(filter_form)
    @filter_form = filter_form
  end

  def items
    @items ||= CollectionPresenter.new(filtered_items, presenter)
  end

  def filters
    []
  end

  def presenter
    SimpleDelegator
  end

  private

  def filtered_items
    CompositeQuery.new(*filters).result(source)
  end
end
