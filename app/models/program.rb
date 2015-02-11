class Program < ActiveRecord::Base
  has_paper_trail

  belongs_to :country
  belongs_to :partner
  has_many :projects
  has_many :vehicles
  has_many :survey_responses, through: :projects
  has_many :tickets, through: :survey_responses

  validates :partner_id, presence: true
  validates :partner_id, uniqueness: { scope: :country_id }
  validates :country_id, presence: true

  scope :with_partner_and_country, -> {
    includes(:partner, :country).order('partners.name asc, countries.name asc')
  }

  def name
    "#{partner.name} – #{country.name}"
  end
end
