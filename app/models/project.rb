class Project < ActiveRecord::Base
  has_paper_trail

  belongs_to :program
  has_many :activities, dependent: :destroy
  has_many :survey_responses, dependent: :destroy
  has_one :sensor, dependent: :destroy
  has_one :country, through: :program
  has_one :partner, through: :program
  has_many :tickets

  searchable do
    text :deployment_code
  end

  validates :wazi_id, presence: true, uniqueness: true
  validates :deployment_code, presence: true, format: { with: RemoteMonitoring::Constants.deployment_code_regex }
  validates :program_id, presence: true
  validates :status, presence: true
  validates :beneficiaries, numericality: { only_integer: true, allow_nil: true }
  validates :latitude, numericality: {
    greater_than_or_equal_to: -90.0,
    less_than_or_equal_to: 90.0
  }
  validates :longitude, numericality: {
    greater_than_or_equal_to: -180.0,
    less_than_or_equal_to: 180.0
  }

  enum status: {
    unknown: 0,
    needs_maintenance: 1,
    flowing: 2,
    inactive: 3,
    needs_visit: 4,
  }

  def self.within_bounds(lat_lo, lng_lo, lat_hi, lng_hi)
    where(latitude: lat_lo..lat_hi, longitude: lng_lo..lng_hi)
  end

  def self.bounds
    bounds = select(<<-SQL.strip_heredoc).to_a.first
      MIN(latitude) AS lat_lo,
      MIN(longitude) AS lng_lo,
      MAX(latitude) AS lat_hi,
      MAX(longitude) AS lng_hi
    SQL

    [
      bounds.lat_lo || -90,
      bounds.lng_lo || -180,
      bounds.lat_hi ||  90,
      bounds.lng_hi ||  180,
    ]
  end

  def contact_phone_numbers
    super || []
  end

  def status_changed_to?(status)
    status_changes = previous_changes[:status]
    status_changes.present? && status_changes.second.to_sym == status.to_sym
  end

  def sensor_timezone_offset
    uri = URI('https://maps.googleapis.com/maps/api/timezone/json')
    params = { :location => "#{self.latitude},#{self.longitude}", timestamp: Time.zone.now.to_i, key: ENV['GOOGLE_MAPS_API_KEY'] }
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get_response(uri)
    offset = JSON.parse(res.body)["rawOffset"]
    offset_in_hours = offset / 3600.0

    offset_in_hours < 0 ? 24 - offset_in_hours.abs : offset_in_hours
  end
end
