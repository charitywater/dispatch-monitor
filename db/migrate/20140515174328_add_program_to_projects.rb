class AddProgramToProjects < ActiveRecord::Migration
  def change
    add_reference :projects, :program, index: true
  end
end
