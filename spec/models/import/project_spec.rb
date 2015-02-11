require 'spec_helper'

module Import
  describe Project do
    let(:import_project) { Import::Project.new }

    describe 'validations' do
      specify do
        expect(import_project).to validate_presence_of :import_codes
      end

      it 'requires the deployment code to be well formatted' do
        expect(import_project).to allow_value(
          'AA.BBB.Q4.00.000.001',
          'AA.BBB.Q4.00.000',
          "AA.BBB.Q4.00.000.001\nAA.BBB.Q4.00.000",
          "AA.BBB.Q4.00.000.001     \nAA.BBB.Q4.00.000",
        ).for(:import_codes)

        expect(import_project).not_to allow_value(
          'AA.BBB.Q4.00.000.001.002',
          'AA.BBB.Q4.00',
          'AA',
          "AA.BBB.Q4.00.000.001\nAA.BBB.Q4.00",
        ).for(:import_codes)
      end
    end

    describe '#deployment_codes' do
      before do
        import_project.import_codes = <<-CODES
        AA.BBB.Q4.00.000.001
        AA.BBB.Q4.00.000
        AA.BBB.Q4.00.001
        AA.BBB.Q4.00.000.002
        CODES
      end

      it 'only returns the project deployment codes from the import codes' do
        expect(import_project.deployment_codes).to eq [
          'AA.BBB.Q4.00.000.001',
          'AA.BBB.Q4.00.000.002',
        ]
      end
    end

    describe '#grant_deployment_codes' do
      before do
        import_project.import_codes = <<-CODES
        AA.BBB.Q4.00.000.001
        AA.BBB.Q4.00.000
        AA.BBB.Q4.00.001
        AA.BBB.Q4.00.000.002
        CODES
      end

      it 'only returns the project deployment codes from the import codes' do
        expect(import_project.grant_deployment_codes).to eq [
          'AA.BBB.Q4.00.000',
          'AA.BBB.Q4.00.001',
        ]
      end
    end
  end
end
