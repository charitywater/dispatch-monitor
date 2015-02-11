class Account < ActiveRecord::Base
  has_paper_trail

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  enum role: {
    admin: 0,
    program_manager: 1,
    viewer: 2
  }

  belongs_to :program
  has_many :email_subscriptions, dependent: :destroy

  validates :name, presence: true
  validates :role, presence: true
  validates :program_id, presence: true, if: :program_manager?
  validate :program_id_is_blank_for_admin

  def name_and_email
    "#{name} <#{email}>"
  end

  private

  def program_id_is_blank_for_admin
    if admin? && program_id.present?
      errors.add(:program_id, "can't be present")
    end
  end
end
