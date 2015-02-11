require 'spec_helper'

describe ProjectPolicy do
  let(:policy) { ProjectPolicy.new(account, project) }

  describe '#show?' do
    context 'for an admin' do
      let(:project) { build(:project) }
      let(:account) { build(:account, :admin) }

      specify do
        expect(policy.show?).to be true
      end
    end

    context 'for a program manager' do
      let(:account) { build(:account, :program_manager) }

      context 'when the project is in their program' do
        let(:project) { build(:project, program: account.program) }

        specify do
          expect(policy.show?).to be true
        end
      end

      context 'when the project is not in their program' do
        let(:project) { build(:project, program: build(:program)) }

        specify do
          expect(policy.show?).to be false
        end
      end
    end

    context 'for an all program viewer' do
      let(:project) { build(:project) }
      let(:account) { build(:account, :viewer, program: nil) }

      specify do
        expect(policy.show?).to eq true
      end
    end

    context 'for a single program viewer' do
      let(:project) { create(:project) }
      let(:program) { create(:program) }
      let(:account) { build(:account, :viewer, program: program) }

      context 'if the object is in my program' do
        before do
          allow(project).to receive(:program) { account.program }
        end

        specify do
          expect(policy.show?).to eq true
        end
      end

      context 'if the object is not in my program' do
        before do
          allow(project).to receive(:program) { double(:other_program) }
        end

        specify do
          expect(policy.show?).to eq false
        end
      end
    end
  end

  describe '#update?' do
    context 'for an admin' do
      let(:account) { build(:account, :admin) }
      let(:project) { build(:project) }

      specify do
        expect(policy.update?).to be true
      end
    end

    context 'for a program manager' do
      let(:account) { build(:account, :program_manager) }
      let(:project) { build(:project, program: account.program) }

      specify do
        expect(policy.update?).to be false
      end
    end
  end

  describe '#destroy?' do
    context 'for an admin' do
      let(:account) { build(:account, :admin) }
      let(:project) { build(:project) }

      specify do
        expect(policy.destroy?).to be true
      end
    end

    context 'for a program manager' do
      let(:account) { build(:account, :program_manager) }
      let(:project) { build(:project, program: account.program) }

      specify do
        expect(policy.destroy?).to be false
      end
    end
  end

  describe '#manage?' do
    context 'for an admin' do
      let(:account) { build(:account, :admin) }
      let(:project) { build(:project) }

      specify do
        expect(policy.manage?).to be true
      end
    end

    context 'for a program manager' do
      let(:account) { build(:account, :program_manager) }
      let(:project) { build(:project, program: account.program) }

      specify do
        expect(policy.manage?).to be false
      end
    end
  end
end
