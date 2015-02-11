module Tickets
  class NonDeletedQuery
    def result(relation = Ticket)
      relation.non_deleted
    end
  end
end
