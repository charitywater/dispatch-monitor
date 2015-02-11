class MakeDueAtNullableForTickets < ActiveRecord::Migration
  def up
    change_column :tickets, :due_at, :datetime, null: true
  end

  def down
    change_column :tickets, :due_at, :datetime, null: false
  end
end
