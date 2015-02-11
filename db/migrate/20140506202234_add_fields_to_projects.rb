class AddFieldsToProjects < ActiveRecord::Migration
  def change
    change_table :projects do |t|
      t.integer   :wazi_id, index: true
      t.integer   :grant_id
      t.string    :quarter
      t.string    :inventory_group
      t.string    :community_name
      t.string    :review_status_name
      t.string    :package_id
      t.string    :region
      t.string    :possible_location_types
      t.string    :inventory_type
      t.decimal   :inventory_cost, precision: 8, scale: 2
      t.decimal   :cost_actual,    precision: 8, scale: 2
      t.integer   :beneficiaries
      t.string    :funding_source
      t.string    :revenue_category
      t.string    :revenue_category_display_label
      t.string    :rehab
      t.float     :latitude
      t.float     :longitude
      t.string    :resubmission_notes
      t.string    :location_type
      t.string    :image_url
      t.string    :plaque_text
      t.string    :package_name
      t.string    :grant_title
      t.string    :grant_deployment_code
      t.date      :completion_date
      t.boolean   :is_ready_to_fund
    end
  end
end
