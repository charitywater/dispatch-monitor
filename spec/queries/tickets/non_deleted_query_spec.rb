require 'spec_helper'

module Tickets
  describe NonDeletedQuery do
    describe '#result' do
      let(:query) { NonDeletedQuery.new }
      let(:non_deleted) { double(:non_deleted) }
      let(:relation) { double(:relation, non_deleted: non_deleted) }

      it 'calls `non_deleted`' do
        expect(query.result(relation)).to eq non_deleted
      end
    end
  end
end
