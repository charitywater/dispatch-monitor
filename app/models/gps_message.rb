class GpsMessage < ActiveRecord::Base
  has_paper_trail

  belongs_to :vehicle

  validates :esn, presence: true
  validates :transmitted_at, presence: true
  validates :payload, presence: true
end
