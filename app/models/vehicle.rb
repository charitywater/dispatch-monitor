class Vehicle < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :program

  has_many :gps_messages

  validates :esn, presence: true, uniqueness: true

  def latest_transmission
    GpsMessage.where(vehicle: self).order(transmitted_at: :desc).first
  end

  def latest_transmission_time
    self.latest_transmission.nil? ? nil : latest_transmission.transmitted_at
  end

  def latest_transmission_latitude
    self.latest_transmission.nil? ? nil : latest_transmission.latitude
  end

  def latest_transmission_longitude
    self.latest_transmission.nil? ? nil : latest_transmission.longitude
  end

  def map_link
    "http://maps.google.com/?q=#{self.latest_transmission_latitude},#{self.latest_transmission_longitude}"
  end
end