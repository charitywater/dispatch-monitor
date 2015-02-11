class AddRoleToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :role, :integer, null: false, default: 0
  end
end
