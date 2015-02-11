module Search
  class ProjectPresenter < Presenter
    def as_json(*_)
      {
        id: id,
        latitude: latitude,
        longitude: longitude,
        status: status,
      }
    end
  end
end
