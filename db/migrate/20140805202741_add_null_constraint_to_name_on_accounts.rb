class AddNullConstraintToNameOnAccounts < ActiveRecord::Migration
  def up
    change_column :accounts, :name, :string, null: false
  end

  def down
    change_column :accounts, :name, :string, null: true
  end
end
