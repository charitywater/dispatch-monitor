class CollectionPresenter < Presenter
  include Enumerable

  def initialize(items, presenter_class)
    super(items)

    @presenter_class = presenter_class
  end

  def each
    items.each do |project|
      yield presenter_class.new(project)
    end
  end

  def as_json(*_)
    map(&:as_json)
  end

  private

  alias_method :items, :__getobj__
  attr_reader :presenter_class
end
