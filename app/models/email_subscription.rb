class EmailSubscription < ActiveRecord::Base
  has_paper_trail

  belongs_to :account

  enum subscription_type: {
    bulk_import_notifications: 0
  }

  validates :account_id, presence: true, uniqueness: {
    scope: :subscription_type,
  }
  validates :subscription_type, presence: true

  delegate :name, :email, :name_and_email, to: :account
end
