require 'spec_helper'

describe EmailSubscriptionPresenter do
  let(:email_subscription) { EmailSubscription.new }
  let(:presenter) { EmailSubscriptionPresenter.new(email_subscription) }

  describe '#subscription_type' do
    before do
      email_subscription.subscription_type = :bulk_import_notifications
    end

    it 'returns the titleized subscription type' do
      expect(presenter.subscription_type).to eq 'Bulk Import Notifications'
    end
  end
end
