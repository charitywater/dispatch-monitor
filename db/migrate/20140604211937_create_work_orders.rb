class CreateWorkOrders < ActiveRecord::Migration
  def change
    create_table :work_orders do |t|
      t.integer :status, null: false
      t.datetime :started_at, null: false
      t.datetime :due_at, null: false
      t.belongs_to :survey_response, index: true, null: false

      t.timestamps
    end
  end
end
