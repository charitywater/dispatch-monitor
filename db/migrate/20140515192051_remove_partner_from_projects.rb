class RemovePartnerFromProjects < ActiveRecord::Migration
  def up
    remove_index :projects, :partner_id
    remove_column :projects, :partner_id
  end

  def down
    add_reference :projects, :partner, index: true
  end
end
