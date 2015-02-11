require 'spec_helper'

module RemoteMonitoring
  module WaziImporting
    describe Project do
      let(:project_importer) { RemoteMonitoring::WaziImporting::Project.new }

      describe '#import' do
        let(:wazi_project) do
          {
            'id' => 1,
            'grant_title' => 'Canada - The North',
            'deployment_code' => 'DEP1',
            'completion_date' => date,
            'district' => 'Fancy District',
            'community_name' => 'Fancy Community',
            'site_name' => 'Fancy Site',
            'state' => 'Fancy State',
            'sub_district' => 'Fancy Sub-District',
            'system_name' => 'Fancy System',
            'water_point_name' => 'Fancy Water Point',
          }
        end
        let(:project) { double(:project, update: true, completion_date: date) }
        let(:partner) { double(:partner) }
        let(:country) { double(:country) }
        let(:program) { double(:program) }
        let(:activity) { double(:activity) }

        before do
          allow(::Project).to receive(:find_or_initialize_by).with(wazi_id: 1) { project }
          allow(Partner).to receive(:find_or_create_by).with(name: 'The North') { partner }
          allow(Country).to receive(:find_or_create_by).with(name: 'Canada') { country }
          allow(Program).to receive(:find_or_create_by).with(partner: partner, country: country) { program }
          allow(Activity).to receive(:completed_construction) { Activity }
          allow(Activity).to receive(:find_or_create_by) { activity }
        end

        context 'grant_title blank' do
          let(:date) { '1950-01-01' }
          let(:wazi_project) do
            {
              'id' => 1,
              'grant_title' => '',
              'deployment_code' => 'DEP1',
              'completion_date' => date,
              'district' => 'Fancy District',
              'community_name' => 'Fancy Community',
              'site_name' => 'Fancy Site',
              'state' => 'Fancy State',
              'sub_district' => 'Fancy Sub-District',
              'system_name' => 'Fancy System',
              'water_point_name' => 'Fancy Water Point',
            }
          end

          it 'does not create the activity' do
            project_importer.import(wazi_project)

            expect(Activity).not_to have_received(:find_or_create_by)
          end

          it 'returns nil' do
            expect(project_importer.import(wazi_project)).to eq nil
          end
        end

        context 'completion_date present' do
          let(:date) { '1950-01-01' }

          it 'creates the activity' do
            project_importer.import(wazi_project)

            expect(Activity).to have_received(:completed_construction)
            expect(Activity).to have_received(:find_or_create_by).with(
              happened_at: date,
              project: project
            )
          end

          it 'updates the project' do
            project_importer.import(wazi_project)

            expect(project).to have_received(:update).with(hash_including(
              'program' => program,
              'status' => :unknown,
              'district' => 'Fancy District',
              'community_name' => 'Fancy Community',
              'site_name' => 'Fancy Site',
              'state' => 'Fancy State',
              'sub_district' => 'Fancy Sub-District',
              'system_name' => 'Fancy System',
              'water_point_name' => 'Fancy Water Point',
            ))
          end

          it 'returns the imported project' do
            expect(project_importer.import(wazi_project)).to eq project
          end

          context 'when the partner name is "A Glimmer of Hope"' do
            let(:wazi_project) do
              {
                'id' => 1,
                'grant_title' => 'Canada - A Glimmer of Hope',
                'deployment_code' => 'DEP1',
                'completion_date' => date,
                'district' => 'Fancy District',
                'community_name' => 'Fancy Community',
                'site_name' => 'Fancy Site',
              }
            end

            let(:new_program) { double(:new_program) }
            let(:new_partner) { double(:new_partner) }

            before do
              allow(Partner).to receive(:find_or_create_by).with(name: 'Relief Society of Tigray') { new_partner }
              allow(Program).to receive(:find_or_create_by).with(partner: new_partner, country: country) { new_program }
            end

            it 'renames it to "Relief Society of Tigray"' do
              project_importer.import(wazi_project)

              expect(Partner).not_to have_received(:find_or_create_by).with(name: 'A Glimmer of Hope')
              expect(project).to have_received(:update).with(hash_including(
                'district' => 'Fancy District',
                'community_name' => 'Fancy Community',
                'site_name' => 'Fancy Site',
                'program' => new_program,
                'status' => :unknown,
              ))
            end
          end
        end

        context 'completion_date blank' do
          let(:date) { nil }

          it 'does not create the activity' do
            project_importer.import(wazi_project)

            expect(Activity).not_to have_received(:find_or_create_by)
          end

          it 'updates the project' do
            project_importer.import(wazi_project)

            expect(project).to have_received(:update).with(hash_including(
              'district' => 'Fancy District',
              'community_name' => 'Fancy Community',
              'site_name' => 'Fancy Site',
              'program' => program,
              'status' => :unknown,
            ))
          end

          it 'returns the imported project' do
            expect(project_importer.import(wazi_project)).to eq project
          end
        end
      end
    end
  end
end
