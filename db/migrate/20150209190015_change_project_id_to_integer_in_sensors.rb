class ChangeProjectIdToIntegerInSensors < ActiveRecord::Migration
  def change
    execute "ALTER TABLE sensors ALTER COLUMN project_id TYPE integer USING (project_id::integer);"
  end
end