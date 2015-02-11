module Map
  class WeeklyLogPresenter < Presenter
    def as_json(*_)
      {
        received_at: received_at,
        total_liters: total_liters,
      }
    end
  end
end
