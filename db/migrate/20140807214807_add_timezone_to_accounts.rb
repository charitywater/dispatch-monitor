class AddTimezoneToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :timezone, :string, default: 'UTC', null: false
  end
end
