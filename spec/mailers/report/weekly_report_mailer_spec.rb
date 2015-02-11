require 'spec_helper'

module Report
  describe WeeklyReportMailer do
    describe '.weekly_report_results' do
      let(:admin_account) do
        double(
          :account,
          id: 5,
          name: 'Kristy Conner',
          name_and_email: 'Kristy Conner <kristy.conner@example.com>',
          program: nil
        )
      end

      let(:program_manager_account) do
        double(
          :account,
          id: 6,
          name: 'Alan Turing',
          name_and_email: 'Alan Turing <alan.turing@example.com>',
          program: rest_program
        )
      end

      let(:rest_program) do
        create(:program, country: create(:country, name: 'Ethiopia'), partner: create(:partner, name: 'REST'))
      end

      let(:newah_program) do
        create(:program, country: create(:country, name: 'Nepal'), partner: create(:partner, name: 'NEWAH'))
      end

      context 'program manager' do
        let(:data) {
          { "results"=>{"program"=>rest_program, "week_start"=>"2014-09-29T00:00:00.000Z"}, "recipient_id"=>program_manager_account.id }
        }

        before do
          Timecop.freeze

          allow(Account).to receive(:find).with(program_manager_account.id) { program_manager_account }
        end

        after do
          Timecop.return
        end

        it 'has the right subject' do
          email = WeeklyReportMailer.weekly_report_results(data)

          expect(email.subject).to eq 'Your Dispatch Monitor Weekly Report'
        end

        it 'has the right recipients' do
          email = WeeklyReportMailer.weekly_report_results(data)

          expect(email.to).to eq ['alan.turing@example.com']
        end

        it 'has the right date' do
          email = WeeklyReportMailer.weekly_report_results(data)

          expect(email.encoded).to include('09/29/2014 to 10/06/2014')
        end

        context 'there are projects in each category' do
          before do
            project_1 = create(:project, :flowing, program: rest_program, deployment_code: "AA.AAA.A1.11.111.001")
            project_2 = create(:project, :flowing, program: rest_program, deployment_code: "AA.AAA.A1.11.111.002")
            project_3 = create(:project, :needs_maintenance, program: rest_program, deployment_code: "AA.AAA.A1.11.111.003")
            project_4 = create(:project, :needs_visit, program: rest_program, deployment_code: "AA.AAA.A1.11.111.004")
            project_5 = create(:project, :flowing, program: newah_program, deployment_code: "AA.AAA.A1.11.111.005")
            project_6 = create(:project, :flowing, program: newah_program, deployment_code: "AA.AAA.A1.11.111.006")
            project_7 = create(:project, :needs_maintenance, program: newah_program, deployment_code: "AA.AAA.A1.11.111.007")
            project_8 = create(:project, :needs_visit, program: newah_program, deployment_code: "AA.AAA.A1.11.111.008")

            create(:activity, :status_changed_to_needs_maintenance, project: project_1, happened_at: Time.new(2014,10,1))
            create(:activity, :status_changed_to_needs_visit, project: project_2, happened_at: Time.new(2014,10,1))
            create(:activity, :status_changed_to_flowing, project: project_3, happened_at: Time.new(2014,10,1))
            create(:activity, :status_changed_to_needs_maintenance, project: project_4, happened_at: Time.new(2014,10,1))
            create(:activity, :status_changed_to_needs_maintenance, project: project_5, happened_at: Time.new(2014,10,2))
            create(:activity, :status_changed_to_needs_visit, project: project_6, happened_at: Time.new(2014,10,3))
            create(:activity, :status_changed_to_flowing, project: project_7, happened_at: Time.new(2014,10,4))
            create(:activity, :status_changed_to_needs_maintenance, project: project_8, happened_at: Time.new(2014,10,8))
          end

          it 'calculates the correct number of status changes to flowing' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to include('1 project was fixed')
          end

          it 'calculates the correct number of status changes to needs_maintenance' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to include('2 new projects require maintenance')
          end

          it 'calculates the correct number of status changes to needs_visit' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to include('1 new project needs a visit')
          end

          it 'includes the flowing deployment codes for the correct program' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to include("AA.AAA.A1.11.111.003")
            expect(email.encoded).to_not include("AA.AAA.A1.11.111.007")
          end

          it 'includes the maintenance deployment codes for the correct program' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to include("AA.AAA.A1.11.111.001")
            expect(email.encoded).to include("AA.AAA.A1.11.111.004")
            expect(email.encoded).to_not include("AA.AAA.A1.11.111.005")
          end

          it 'includes the visit deployment codes for the correct program' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to include("AA.AAA.A1.11.111.002")
            expect(email.encoded).to_not include("AA.AAA.A1.11.111.006")
          end
        end
      end

      context 'admin' do
        let(:data) {
          { "results"=>{"program"=>nil, "week_start"=>"2014-09-29T00:00:00.000Z"}, "recipient_id"=>admin_account.id }
        }
        before do
          Timecop.freeze

          allow(Account).to receive(:find).with(admin_account.id) { admin_account }
        end

        after do
          Timecop.return
        end

        it 'has the right subject' do
          email = WeeklyReportMailer.weekly_report_results(data)

          expect(email.subject).to eq 'Your Dispatch Monitor Weekly Report'
        end

        it 'has the right recipients' do
          email = WeeklyReportMailer.weekly_report_results(data)

          expect(email.to).to eq ['kristy.conner@example.com']
        end

        it 'has the right date' do
          email = WeeklyReportMailer.weekly_report_results(data)

          expect(email.encoded).to include('09/29/2014 to 10/06/2014')
        end

        context 'there are some projects in each category' do
          before do
            project_1 = create(:project, :flowing, program: rest_program, deployment_code: "AA.AAA.A1.11.111.001")
            project_2 = create(:project, :flowing, program: rest_program, deployment_code: "AA.AAA.A1.11.111.002")
            project_3 = create(:project, :needs_maintenance, program: rest_program, deployment_code: "AA.AAA.A1.11.111.003")
            project_4 = create(:project, :needs_visit, program: rest_program, deployment_code: "AA.AAA.A1.11.111.004")
            project_5 = create(:project, :flowing, program: newah_program, deployment_code: "AA.AAA.A1.11.111.005")
            project_6 = create(:project, :flowing, program: newah_program, deployment_code: "AA.AAA.A1.11.111.006")
            project_7 = create(:project, :needs_maintenance, program: newah_program, deployment_code: "AA.AAA.A1.11.111.007")
            project_8 = create(:project, :needs_visit, program: newah_program, deployment_code: "AA.AAA.A1.11.111.008")

            create(:activity, :status_changed_to_needs_maintenance, project: project_1, happened_at: Time.new(2014,10,1))
            create(:activity, :status_changed_to_needs_visit, project: project_2, happened_at: Time.new(2014,10,1))
            create(:activity, :status_changed_to_flowing, project: project_3, happened_at: Time.new(2014,10,1))
            create(:activity, :status_changed_to_needs_maintenance, project: project_4, happened_at: Time.new(2014,10,1))
            create(:activity, :status_changed_to_needs_maintenance, project: project_5, happened_at: Time.new(2014,10,2))
            create(:activity, :status_changed_to_needs_visit, project: project_6, happened_at: Time.new(2014,10,3))
            create(:activity, :status_changed_to_flowing, project: project_7, happened_at: Time.new(2014,10,4))
            create(:activity, :status_changed_to_needs_maintenance, project: project_8, happened_at: Time.new(2014,10,8))
          end

          it 'calculates the correct number of status changes to flowing' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to include('2 projects were fixed')
          end

          it 'calculates the correct number of status changes to needs_maintenance' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to include('3 new projects require maintenance')
          end

          it 'calculates the correct number of status changes to needs_visit' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to include('2 new projects need a visit')
          end

          it 'includes the flowing deployment codes' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to include("AA.AAA.A1.11.111.003")
            expect(email.encoded).to include("AA.AAA.A1.11.111.007")
          end

          it 'includes the maintenance deployment codes' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to include("AA.AAA.A1.11.111.001")
            expect(email.encoded).to include("AA.AAA.A1.11.111.004")
            expect(email.encoded).to include("AA.AAA.A1.11.111.005")
          end

          it 'includes the visit deployment codes' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to include("AA.AAA.A1.11.111.002")
            expect(email.encoded).to include("AA.AAA.A1.11.111.006")
          end
        end

        context 'there is only one needs maintenance project' do
          before do
            project_1 = create(:project, :flowing, program: rest_program, deployment_code: "AA.AAA.A1.11.111.001")
            project_2 = create(:project, :flowing, program: rest_program, deployment_code: "AA.AAA.A1.11.111.002")
            project_3 = create(:project, :needs_maintenance, program: rest_program, deployment_code: "AA.AAA.A1.11.111.003")
            project_4 = create(:project, :needs_visit, program: rest_program, deployment_code: "AA.AAA.A1.11.111.004")
            project_5 = create(:project, :flowing, program: newah_program, deployment_code: "AA.AAA.A1.11.111.005")
            project_6 = create(:project, :flowing, program: newah_program, deployment_code: "AA.AAA.A1.11.111.006")
            project_7 = create(:project, :needs_maintenance, program: newah_program, deployment_code: "AA.AAA.A1.11.111.007")
            project_8 = create(:project, :needs_visit, program: newah_program, deployment_code: "AA.AAA.A1.11.111.008")

            create(:activity, :status_changed_to_needs_maintenance, project: project_1, happened_at: Time.new(2014,10,1))
            create(:activity, :status_changed_to_needs_visit, project: project_2, happened_at: Time.new(2014,10,1))
            create(:activity, :status_changed_to_flowing, project: project_3, happened_at: Time.new(2014,10,1))
            create(:activity, :status_changed_to_needs_visit, project: project_6, happened_at: Time.new(2014,10,3))
            create(:activity, :status_changed_to_flowing, project: project_7, happened_at: Time.new(2014,10,4))
            create(:activity, :status_changed_to_needs_maintenance, project: project_8, happened_at: Time.new(2014,10,8))
          end

          it 'calculates the correct number of status changes to needs_maintenance' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to include('1 new project requires maintenance')
          end

          it 'includes the maintenance deployment codes' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to include("AA.AAA.A1.11.111.001")
            expect(email.encoded).to_not include("AA.AAA.A1.11.111.004")
          end
        end

        context 'there are no projects that need a visit' do
          before do
            project_1 = create(:project, :flowing, program: rest_program, deployment_code: "AA.AAA.A1.11.111.001")
            project_2 = create(:project, :flowing, program: rest_program, deployment_code: "AA.AAA.A1.11.111.002")
            project_3 = create(:project, :needs_maintenance, program: rest_program, deployment_code: "AA.AAA.A1.11.111.003")
            project_4 = create(:project, :needs_visit, program: rest_program, deployment_code: "AA.AAA.A1.11.111.004")
            project_5 = create(:project, :flowing, program: newah_program, deployment_code: "AA.AAA.A1.11.111.005")
            project_6 = create(:project, :flowing, program: newah_program, deployment_code: "AA.AAA.A1.11.111.006")
            project_7 = create(:project, :needs_maintenance, program: newah_program, deployment_code: "AA.AAA.A1.11.111.007")
            project_8 = create(:project, :needs_visit, program: newah_program, deployment_code: "AA.AAA.A1.11.111.008")

            create(:activity, :status_changed_to_needs_maintenance, project: project_1, happened_at: Time.new(2014,10,1))
            create(:activity, :status_changed_to_flowing, project: project_3, happened_at: Time.new(2014,10,1))
            create(:activity, :status_changed_to_flowing, project: project_7, happened_at: Time.new(2014,10,4))
            create(:activity, :status_changed_to_needs_maintenance, project: project_8, happened_at: Time.new(2014,10,8))
          end

          it 'calculates the correct number of status changes to needs_visit' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to include('0 new projects need a visit')
          end

          it 'does not include the needs_visit deployment codes' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to_not include("New projects that need a visit:")
          end
        end

        context 'project changes status twice in a week' do
          before do
            project_3 = create(:project, :needs_maintenance, program: rest_program, deployment_code: "AA.AAA.A1.11.111.003")

            create(:activity, :status_changed_to_needs_visit, project: project_3, happened_at: Time.new(2014,10,1,5))
            create(:activity, :status_changed_to_flowing, project: project_3, happened_at: Time.new(2014,10,3,5))
          end

          it 'calculates the correct number of status changes to needs_visit' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to include('0 new projects need a visit')
          end

          it 'calculates the correct number of status changes to flowing' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to include('1 project was fixed')
          end

          it 'does not include the needs_visit deployment codes' do
            email = WeeklyReportMailer.weekly_report_results(data)

            expect(email.encoded).to_not include("New projects that need a visit:")
          end
        end
      end
    end
  end
end