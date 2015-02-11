require 'spec_helper'

module Import
  describe SourceObservationMailer do
    describe '.results' do
      let(:account) do
        double(
          :account,
          name: 'Kristy Conner',
          name_and_email: 'Kristy Conner <kristy.conner@example.com>',
        )
      end
      let(:survey_type) { :source_observation_v1 }
      let(:data) { { fs_survey_id: 1, fs_response_id: 2 } }

      before do
        allow(Account).to receive(:find).with(5) { account }
      end

      it 'has the right subject' do
        email = SourceObservationMailer.results(
          results: [survey_type: survey_type, created: [data]], recipient_id: 5
        )
        expect(email.subject).to eq 'Your Source Observation import has finished'
      end

      it 'has the right recipient' do
        email = SourceObservationMailer.results(
          results: [survey_type: survey_type, created: [data]], recipient_id: 5
        )
        expect(email.to).to eq ['kristy.conner@example.com']
        expect(email.encoded).to include 'Dear Kristy Conner,'
      end

      context 'created' do
        it 'shows the text when present' do
          email = SourceObservationMailer.results(
            results: [
              { survey_type: :source_observation_v1, created: [data] },
              { survey_type: :test_source_observation_v02, created: [data, data] },
            ],
            recipient_id: 5
          )
          expect(email.encoded).to match(/
            Source\sObservation\sV1
            .*?
            1\ssurvey\sresponse\swas\screated
            .*?
            Test\sSource\sObservation\sV\.02
            .*?
            2\ssurvey\sresponses\swere\screated
          /mx)
        end

        it 'hides the text when blank' do
          email = SourceObservationMailer.results(
            results: [survey_type: survey_type, created: []], recipient_id: 5
          )
          expect(email.encoded).not_to include('created')
        end
      end

      context 'updated' do
        it 'shows the text when present' do
          email = SourceObservationMailer.results(
            results: [survey_type: survey_type, updated: [data]], recipient_id: 5
          )
          expect(email.encoded).to include('1 survey response was updated')

          email = SourceObservationMailer.results(
            results: [survey_type: survey_type, updated: [data, data]], recipient_id: 5
          )
          expect(email.encoded).to include('2 survey responses were updated')
        end

        it 'hides the text when blank' do
          email = SourceObservationMailer.results(
            results: [survey_type: survey_type, updated: []], recipient_id: 5
          )
          expect(email.encoded).not_to include('updated')
        end
      end

      context 'invalid' do
        it 'shows the text when present' do
          email = SourceObservationMailer.results(
            results: [survey_type: survey_type, invalid: [data]], recipient_id: 5
          )
          expect(email.encoded).to include('1 survey response was invalid')

          email = SourceObservationMailer.results(
            results: [survey_type: survey_type, invalid: [data, data]], recipient_id: 5
          )
          expect(email.encoded).to include('2 survey responses were invalid')
        end

        it 'hides the text when blank' do
          email = SourceObservationMailer.results(
            results: [survey_type: survey_type, invalid: []], recipient_id: 5
          )
          expect(email.encoded).not_to include('invalid')
        end
      end

      context 'count for projects that need visit' do
        context 'when there are projects that need visit' do
          let!(:project) do
            create(
              :project,
              :needs_visit,
              deployment_code: 'AA.AAA.Q4.00.001.001'
            )
          end

          before do
            create(
              :survey_response,
              fs_survey_id: 1,
              fs_response_id: 2,
              project: project
            )
          end

          it 'shows the text' do
            email = SourceObservationMailer.results(
              results: [survey_type: survey_type, created: [data]],
              recipient_id: 5
            )
            expect(email.encoded).to include('1 project needs to be visited')
          end
        end

        context 'when there are no projects that need visit' do
          it 'hides the text' do
            email = SourceObservationMailer.results(
              results: [survey_type: survey_type, created: []],
              recipient_id: 5
            )
            expect(email.encoded).not_to include('visit')
          end
        end
      end

      context 'deployment codes for needs_maintenance projects' do
        let!(:project) do
          create(:project, project_status, deployment_code: 'AA.AAA.Q4.00.001.001')
        end

        before do
          create(:survey_response, fs_survey_id: 1, fs_response_id: 2, project: project)
          create(:survey_response, fs_survey_id: 1, fs_response_id: 3, project: project)
        end

        context 'when there are needs_maintenance projects' do
          let(:project_status) { :needs_maintenance }

          it 'shows the project deployment code when created' do
            email = SourceObservationMailer.results(
              results: [survey_type: survey_type, created: [data]], recipient_id: 5
            )
            expect(email.encoded).to include('AA.AAA.Q4.00.001.001')
          end

          it 'shows the project deployment code when updated' do
            email = SourceObservationMailer.results(
              results: [survey_type: survey_type, updated: [data]], recipient_id: 5
            )
            expect(email.encoded).to include('AA.AAA.Q4.00.001.001')
          end

          it 'does not show the project deployment code when invalid' do
            email = SourceObservationMailer.results(
              results: [survey_type: survey_type, invalid: [data]], recipient_id: 5
            )
            expect(email.encoded).not_to include('AA.AAA.Q4.00.001.001')
          end

          it 'only shows the project deployment code once' do
            email = SourceObservationMailer.results(
              results: [
                survey_type: survey_type,
                created: [data],
                updated: [data],
                invalid: [data],
              ],
              recipient_id: 5
            )
            expect(email.encoded).to include('AA.AAA.Q4.00.001.001')
            expect(email.encoded).not_to match(/(.*AA\.AAA\.Q4\.00\.001\.001.*){2,}/m)
          end
        end

        context 'when there are no needs_maintenance projects' do
          let(:project_status) { :flowing }

          it 'does not show the project deployment code when created, updated or invalid' do
            email = SourceObservationMailer.results(
              results: [
                survey_type: survey_type,
                created: [data],
                updated: [data],
                invalid: [data],
              ],
              recipient_id: 5
            )
            expect(email.encoded).not_to include('AA.AAA.Q4.00.001.001')
          end
        end
      end
    end
  end
end
