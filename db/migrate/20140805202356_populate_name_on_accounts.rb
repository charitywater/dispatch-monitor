class PopulateNameOnAccounts < ActiveRecord::Migration
  class Account < ActiveRecord::Base
  end

  def up
    Account.reset_column_information
    Account.update_all('name = email')
  end

  def down
    Account.reset_column_information
    Account.update_all(name: nil)
  end
end
