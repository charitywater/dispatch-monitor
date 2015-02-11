class AddManuallyCreatedByToActivities < ActiveRecord::Migration
  def change
    add_reference :activities, :manually_created_by, index: true
  end
end
