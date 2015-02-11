class ByStatusQuery < Struct.new(:status)
  def result(relation)
    if relation.statuses.key?(status.to_s)
      relation.public_send(status.to_sym)
    else
      relation
    end
  end
end
