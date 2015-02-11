class AddActivityTypeToActivities < ActiveRecord::Migration
  class Activity < ActiveRecord::Base
  end

  def up
    add_column :activities, :activity_type, :integer

    Activity.reset_column_information
    up_hash.each do |name, type|
      Activity.where(name: name).update_all(activity_type: type)
    end

    change_column :activities, :activity_type, :integer, null: false

    remove_column :activities, :name
  end

  def down
    add_column :activities, :name, :string

    Activity.reset_column_information
    up_hash.each do |name, type|
      Activity.where(activity_type: type).update_all(name: name)
    end

    change_column :activities, :name, :string, null: false

    remove_column :activities, :activity_type
  end

  private

  def up_hash
    @up_hash ||= {
      'Completed construction' => 0,
      'Survey received' => 1,
    }
  end
end
