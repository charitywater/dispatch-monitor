class CreateJobData < ActiveRecord::Migration
  def change
    create_table :job_data do |t|
      t.json :data
      t.timestamps
    end
  end
end
