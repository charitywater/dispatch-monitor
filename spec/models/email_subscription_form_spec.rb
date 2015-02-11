require 'spec_helper'

describe EmailSubscriptionForm do
  let(:email_subscription_form) { EmailSubscriptionForm.new }

  describe '#available_accounts' do
    let!(:subscribed) { create(:account, :program_manager) }
    let!(:subscription) { create(:email_subscription, account: subscribed) }

    let!(:not_subscribed) { create(:account, :program_manager) }

    it 'returns the not-yet subscribed accounts' do
      expect(email_subscription_form.available_accounts).to eq [not_subscribed]
    end
  end
end
