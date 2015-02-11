require 'spec_helper'

describe TicketPolicy do
  let(:ticket) { build(:ticket) }
  let(:policy) { TicketPolicy.new(account, ticket) }

  describe '#create?' do
    context 'as an admin' do
      let(:account) { build(:account, :admin) }

      specify do
        expect(policy.create?).to eq true
      end
    end

    context 'as a program manager' do
      let(:account) { build(:account, :program_manager) }

      context 'if the object is in my program' do
        before do
          allow(ticket).to receive(:program) { account.program }
        end

        specify do
          expect(policy.create?).to eq true
        end
      end

      context 'if the object is not in my program' do
        before do
          allow(ticket).to receive(:program) { double(:other_program) }
        end

        specify do
          expect(policy.create?).to eq false
        end
      end
    end

    context 'as a viewer of all programs' do
      let(:account) { build(:account, :viewer, program: nil) }

      specify do
        expect(policy.create?).to eq false
      end
    end

    context 'as a viewer of one program' do
      let(:program) { create(:program) }
      let(:account) { build(:account, :viewer, program: program) }

      context 'if the object is in my program' do
        before do
          allow(ticket).to receive(:program) { account.program }
        end

        specify do
          expect(policy.create?).to eq false
        end
      end

      context 'if the object is not in my program' do
        before do
          allow(ticket).to receive(:program) { double(:other_program) }
        end

        specify do
          expect(policy.create?).to eq false
        end
      end
    end
  end

  describe '#show?' do
    context 'as an admin' do
      let(:account) { build(:account, :admin) }

      specify do
        expect(policy.show?).to eq true
      end
    end

    context 'as a program manager' do
      let(:account) { build(:account, :program_manager) }

      context 'if the object is in my program' do
        before do
          allow(ticket).to receive(:program) { account.program }
        end

        specify do
          expect(policy.show?).to eq true
        end
      end

      context 'if the object is not in my program' do
        before do
          allow(ticket).to receive(:program) { double(:other_program) }
        end

        specify do
          expect(policy.show?).to eq false
        end
      end
    end

    context 'as a viewer of all programs' do
      let(:account) { build(:account, :viewer, program: nil) }

      specify do
        expect(policy.show?).to eq true
      end
    end

    context 'as a viewer of one program' do
      let(:program) { create(:program) }
      let(:account) { build(:account, :viewer, program: program) }

      context 'if the object is in my program' do
        before do
          allow(ticket).to receive(:program) { account.program }
        end

        specify do
          expect(policy.show?).to eq true
        end
      end

      context 'if the object is not in my program' do
        before do
          allow(ticket).to receive(:program) { double(:other_program) }
        end

        specify do
          expect(policy.show?).to eq false
        end
      end
    end
  end

  describe '#update?' do
    context 'as an admin' do
      let(:account) { build(:account, :admin) }

      specify do
        expect(policy.update?).to be true
      end
    end

    context 'as a program manager' do
      let(:account) { build(:account, :program_manager) }

      context 'if the object is in my program' do
        before do
          allow(ticket).to receive(:program) { account.program }
        end

        specify do
          expect(policy.update?).to eq true
        end
      end

      context 'if the object is not in my program' do
        before do
          allow(ticket).to receive(:program) { double(:other_program) }
        end

        specify do
          expect(policy.update?).to eq false
        end
      end
    end

    context 'as a viewer of all programs' do
      let(:account) { build(:account, :viewer, program: nil) }

      specify do
        expect(policy.update?).to eq false
      end
    end

    context 'as a viewer of one program' do
      let(:program) { create(:program) }
      let(:account) { build(:account, :viewer, program: program) }

      context 'if the object is in my program' do
        before do
          allow(ticket).to receive(:program) { account.program }
        end

        specify do
          expect(policy.update?).to eq false
        end
      end

      context 'if the object is not in my program' do
        before do
          allow(ticket).to receive(:program) { double(:other_program) }
        end

        specify do
          expect(policy.update?).to eq false
        end
      end
    end
  end

  describe '#destroy?' do
    let(:ticket) { build(:ticket) }

    context 'for admins' do
      let(:account) { build(:account, :admin) }

      specify do
        expect(policy.destroy?).to be true
      end
    end

    context 'for program managers' do
      let(:account) { build(:account, :program_manager) }

      specify do
        expect(policy.destroy?).to be false
      end
    end
  end
end
