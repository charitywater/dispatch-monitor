class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :name
      t.belongs_to :project, index: true
      t.date :date

      t.timestamps
    end
  end
end
