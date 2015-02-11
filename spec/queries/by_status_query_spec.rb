require 'spec_helper'

describe ByStatusQuery do
  describe '#result' do
    let!(:unknown) { create(:project, :unknown) }
    let!(:needs_maintenance) { create(:project, :needs_maintenance) }
    let!(:flowing) { create(:project, :flowing) }

    context 'with a valid status' do
      let(:query) { ByStatusQuery.new(:unknown) }

      it 'returns only the records matching the status' do
        expect(query.result(Project.all)).to eq [unknown]
      end
    end

    context 'with an invalid status' do
      let(:query) { ByStatusQuery.new(:not_a_thing) }

      it 'returns all the records' do
        expect(query.result(Project.all)).to match_array [unknown, needs_maintenance, flowing]
      end
    end
  end
end
