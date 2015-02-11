module Tickets
  class OrderedQuery
    def result(relation = Ticket)
      relation.order(id: :asc, status: :asc, completed_at: :desc, due_at: :asc)
    end
  end
end
