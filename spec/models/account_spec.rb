require 'spec_helper'

describe Account do
  let(:account) { Account.new }

  describe 'associations' do
    specify do
      expect(account).to belong_to(:program)
    end

    specify do
      expect(account).to have_many(:email_subscriptions).dependent(:destroy)
    end
  end

  describe 'validations' do
    specify do
      expect(account).to validate_presence_of(:name)
    end

    specify do
      expect(account).to validate_presence_of(:email)
    end

    specify do
      expect(account).to validate_presence_of(:password)
    end

    specify do
      expect(account).to ensure_length_of(:password).is_at_least(8)
    end

    specify do
      expect(account).to validate_presence_of(:role)
    end

    describe '#program_id' do
      context 'when the role is program manager' do
        it 'is required when the role is program_manager' do
          account.role = :program_manager

          expect(account).to validate_presence_of(:program_id)
        end
      end

      context 'when the role is admin' do
        before do
          account.role = :admin
        end

        context 'when program id is present' do
          it 'is valid' do
            account.program_id = 1
            account.valid?

            expect(account.errors[:program_id]).to include("can't be present")
          end
        end

        context 'when program id is nil' do
          it 'is valid' do
            account.program_id = nil
            account.valid?

            expect(account.errors[:program_id]).to be_empty
          end
        end
      end
    end

    describe '#name_and_email' do
      before do
        account.name = 'Rebecca Johnson'
        account.email = 'rebecca.johnson@example.com'
      end

      it 'returns a String in the format "Full Name <email>"' do
        expect(account.name_and_email).to eq(
          'Rebecca Johnson <rebecca.johnson@example.com>'
        )
      end
    end
  end
end
