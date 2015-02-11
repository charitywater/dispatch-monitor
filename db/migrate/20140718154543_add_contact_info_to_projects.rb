class AddContactInfoToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :contact_name, :string
    add_column :projects, :contact_email, :string
    add_column :projects, :contact_phone_numbers, :string, array: true
  end
end
