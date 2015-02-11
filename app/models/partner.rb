class Partner < ActiveRecord::Base
  has_paper_trail

  has_many :programs
  has_many :projects, through: :programs

  validates :name, presence: true, uniqueness: true
  validate :name_is_allowed

  NAME_MAP = {
    'A Glimmer of Hope' => 'Relief Society of Tigray'
  }

  private

  def name_is_allowed
    if NAME_MAP.keys.include?(name)
      errors.add(:name, 'is not allowed anymore')
    end
  end
end
