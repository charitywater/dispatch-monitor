require 'spec_helper'

describe AccountPresenter do
  let(:presenter) { AccountPresenter.new(account) }

  describe '#role' do
    let(:account) { double(:program_manager, role: :program_manager) }

    it 'is titleized' do
      expect(presenter.role).to eq 'Program Manager'
    end
  end

  describe '#program_name' do
    context 'for admins' do
      let(:account) { double(:admin, program: nil) }

      it 'is N/A' do
        expect(presenter.program_name).to eq 'N/A'
      end
    end

    context 'for program managers' do
      let(:account) { double(:program_manager, program: program) }
      let(:program) { double(:program, name: 'This is the program name') }

      it 'is the program name' do
        expect(presenter.program_name).to eq 'This is the program name'
      end
    end
  end

  describe '#as_json' do
    let(:account) { double(:program_manager, email: 'hello@example.com') }

    it 'returns the email' do
      expect(presenter.as_json).to eq(
        email: 'hello@example.com'
      )
    end
  end
end
