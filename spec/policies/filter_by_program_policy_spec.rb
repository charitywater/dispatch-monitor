require 'spec_helper'

describe FilterByProgramPolicy do
  let(:policy) { FilterByProgramPolicy.new(account, double(:object)) }

  describe '#filter_by_program?' do
    context 'for an admin' do
      let(:account) { build(:account, :admin) }

      it 'is true' do
        expect(policy.filter_by_program?).to be true
      end
    end

    context 'for a program manager' do
      let(:account) { build(:account, :program_manager) }

      it 'is false' do
        expect(policy.filter_by_program?).to be false
      end
    end

    context 'for a single program viewer' do
      let(:program) { build(:program) }
      let(:account) { build(:account, :viewer, program: program) }

      it 'is false' do
        expect(policy.filter_by_program?).to be false
      end
    end

    context 'for an all programs viewer' do
      let(:account) { build(:account, :viewer, program: nil) }

      it 'is true' do
        expect(policy.filter_by_program?).to be true
      end
    end
  end
end
