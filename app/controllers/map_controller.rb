class MapController < ApplicationController
  def show
    @navbar_class = 'expand-full'
    @map = ProjectMap.new(FilterForm.new(filter_params))
  end
end
