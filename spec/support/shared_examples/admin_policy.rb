shared_examples_for 'an admin policy' do
  describe '#manage?' do
    context 'as an admin' do
      let(:account) { build(:account, :admin) }

      it 'returns true' do
        expect(policy.manage?).to eq true
      end
    end

    context 'as a program manager' do
      let(:account) { build(:account, :program_manager) }

      it 'returns false' do
        expect(policy.manage?).to eq false
      end
    end
  end
end
