class AddExtraFieldsToGpsMessage < ActiveRecord::Migration
  def change
    add_column :gps_messages, :message_type, :string
    add_column :gps_messages, :latitude, :string
    add_column :gps_messages, :longitude, :string
    add_column :gps_messages, :confidence, :string
  end
end
