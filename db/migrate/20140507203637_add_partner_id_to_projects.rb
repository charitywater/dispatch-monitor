class AddPartnerIdToProjects < ActiveRecord::Migration
  def change
    add_reference :projects, :partner, index: true
  end
end
