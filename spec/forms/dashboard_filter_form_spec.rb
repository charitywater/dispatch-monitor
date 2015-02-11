require 'spec_helper'

describe DashboardFilterForm do
  let(:form) { DashboardFilterForm.new }

  describe '#days' do
    context 'when blank' do
      before do
        form.days = ''
      end

      it 'returns 30' do
        expect(form.days).to eq 30
      end
    end

    context 'when it is a non-numeric string' do
      before do
        form.days = 'NON-NUMERIC'
      end

      it 'returns 30' do
        expect(form.days).to eq 30
      end
    end

    context 'when nil' do
      before do
        form.days = nil
      end

      it 'returns 30' do
        expect(form.days).to eq 30
      end
    end

    context 'when it is a number as a string' do
      before do
        form.days = ' 15'
      end

      it 'returns the number' do
        expect(form.days).to eq 15
      end
    end

    context 'when it is a number' do
      before do
        form.days = 12
      end

      it 'returns the number' do
        expect(form.days).to eq 12
      end
    end

    context 'when it is negative' do
      before do
        form.days = -1
      end

      it 'returns 30' do
        expect(form.days).to eq 30
      end
    end
  end

  describe '#since' do
    before do
      form.days = 5

      Timecop.freeze
    end

    after do
      Timecop.return
    end

    it 'converts the days to a DateTime' do
      expect(form.since).to eq 5.days.ago
    end
  end

  describe '#to_query_params' do
    before do
      form.program_id = 123
      form.days = 5
    end

    it 'returns the attributes wrapped with the param name' do
      expect(form.to_query_params).to eq('filters' => {
        program_id: 123,
        days: 5,
      })
    end
  end
end
