require 'spec_helper'

describe EmailSubscription do
  let(:email_subscription) { EmailSubscription.new }

  describe 'associations' do
    specify do
      expect(email_subscription).to belong_to(:account)
    end
  end

  describe 'validations' do
    specify do
      expect(email_subscription).to validate_presence_of(:account_id)
    end

    specify do
      expect(email_subscription).to validate_presence_of(:subscription_type)
    end

    specify do
      EmailSubscription.create(account_id: 6, subscription_type: 0)

      expect(email_subscription).to validate_uniqueness_of(:account_id).scoped_to(:subscription_type)
    end

    it 'stores subscription_type as an enum' do
      [
        :bulk_import_notifications,
      ].each { |s| email_subscription.subscription_type = s }

      expect { email_subscription.subscription_type = :whatever }.to raise_error
    end
  end

  describe '#name_and_email' do
    let(:account) { build(:account, name: 'Roxanne Padilla', email: 'roxanne.padilla@example.com') }

    before do
      email_subscription.account = account
    end

    specify do
      expect(email_subscription.name_and_email).to eq 'Roxanne Padilla <roxanne.padilla@example.com>'
      expect(email_subscription.name).to eq 'Roxanne Padilla'
      expect(email_subscription.email).to eq 'roxanne.padilla@example.com'
    end
  end
end
