class OrderedQuery < Struct.new(:order)
  def result(relation)
    relation.order(order)
  end
end
