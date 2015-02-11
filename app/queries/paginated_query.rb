class PaginatedQuery < Struct.new(:page)
  def result(relation)
    relation.page(page)
  end
end
