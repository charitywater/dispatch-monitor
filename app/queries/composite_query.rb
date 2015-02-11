class CompositeQuery
  def initialize(*queries)
    @queries = queries
  end

  def result(relation)
    queries.reduce(relation) do |new_relation, query|
      query.result(new_relation)
    end
  end

  private

  attr_reader :queries
end
