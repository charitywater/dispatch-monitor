require 'spec_helper'

describe FilterForm do
  let(:form) { FilterForm.new(current_account: account) }
  let(:account) { double(:account) }

  specify do
    expect(FilterForm.policy_class).to eq FilterByProgramPolicy
  end

  specify do
    expect(form.param_name).to eq 'filters'
  end

  describe '#program' do
    let(:program) { double(:program) }

    context 'for admins' do
      let(:account) { build(:account, :admin) }

      context 'when the program is specified' do
        before do
          allow(Program).to receive(:find_by).with(id: 123) { program }
        end

        it 'returns the specified program' do
          form.program_id = 123
          expect(form.program).to eq program
        end
      end

      context 'when no program is specified' do
        before do
          allow(Program).to receive(:find_by) { nil }
        end

        it 'returns the NilProgram' do
          expect(form.program).to be_a NilProgram
        end
      end
    end

    context 'for program managers' do
      let(:account) { double(:program_manager, program: program) }

      it 'returns the program manager’s program' do
        expect(form.program).to eq program
      end
    end
  end

  describe '#to_query_params' do
    before do
      form.program_id = 123
      form.status = 'status'
      form.page = 321
      form.sort_column = "deployment_code"
      form.sort_direction = "desc"
    end

    it 'returns the attributes wrapped with the param name' do
      expect(form.to_query_params).to eq('filters' => {
        program_id: 123,
        status: 'status',
        page: 321,
        sort_column: "deployment_code",
        sort_direction: "desc"
      })
    end
  end

  describe '#to_query_params_for_pagination' do
    before do
      form.program_id = 123
      form.status = 'status'
    end

    it 'returns the attributes wrapped with the param name' do
      expect(form.to_query_params_for_pagination).to eq('filters' => {
        program_id: 123,
        status: 'status',
        sort_column: nil,
        sort_direction: nil
      })
    end
  end

  describe '#bounds' do
    let(:account) { double(:account, program: program) }
    let(:program) { double(:program) }
    let(:projects) { double(:projects, bounds: [-1, -2, 1, 2]) }

    before do
      allow(program).to receive(:projects) { projects }
    end

    it 'returns the [min lat, min long, max lat, max long]' do
      expect(form.bounds).to eq [-1, -2, 1, 2]
    end
  end
end
