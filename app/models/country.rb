class Country < ActiveRecord::Base
  has_paper_trail

  has_many :programs
  has_many :projects, through: :programs

  validates :name, uniqueness: true, presence: true
end
