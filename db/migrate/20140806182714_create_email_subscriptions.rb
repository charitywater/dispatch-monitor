class CreateEmailSubscriptions < ActiveRecord::Migration
  def change
    create_table :email_subscriptions do |t|
      t.integer :subscription_type, null: false
      t.belongs_to :account, null: false, index: true
      t.timestamps
    end

    add_index :email_subscriptions, [:subscription_type, :account_id], unique: true
  end
end
