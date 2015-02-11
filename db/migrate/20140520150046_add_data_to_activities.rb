class AddDataToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :data, :json, default: {}
  end
end
