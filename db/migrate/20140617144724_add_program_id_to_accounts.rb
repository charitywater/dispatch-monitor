class AddProgramIdToAccounts < ActiveRecord::Migration
  def change
    add_reference :accounts, :program, index: true
  end
end
