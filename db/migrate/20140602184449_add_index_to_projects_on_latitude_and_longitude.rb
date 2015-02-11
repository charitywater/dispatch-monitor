class AddIndexToProjectsOnLatitudeAndLongitude < ActiveRecord::Migration
  def change
    add_index :projects, [:longitude, :latitude]
  end
end
