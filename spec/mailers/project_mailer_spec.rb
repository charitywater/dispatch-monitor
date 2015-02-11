require 'spec_helper'

describe ProjectMailer do
  describe '#needs_maintenance' do
    let(:project) do
      build(
        :project,
        :needs_maintenance,
        id: 3,
        deployment_code: 'AA.AAA.Q1.00.111.111',
        community_name: 'Fancy Community'
      )
    end

    let(:survey_response) do
      build(
        :survey_response,
        id: 6,
        fs_survey_id: 10,
        fs_response_id: 20,
        submitted_at: DateTime.strptime('2001-02-03T04:05:06+00:00', '%Y-%m-%dT%H:%M:%S%z'),
        project: project,
      )
    end

    before do
      allow(Project).to receive(:find).with(3) { project }
      allow(SurveyResponse).to receive(:find).with(6) { survey_response }
    end

    it 'sends a multipart/alternative email' do
      email = ProjectMailer.needs_maintenance(survey_response.id)

      expect(email).to be_multipart
    end

    it 'has the right subject' do
      email = ProjectMailer.needs_maintenance(survey_response.id)

      expect(email.subject).to eq 'Fancy Community (AA.AAA.Q1.00.111.111) needs maintenance'
    end

    it 'contains a link to the project page' do
      email = ProjectMailer.needs_maintenance(survey_response.id)

      expect(email.html_part.encoded).to have_link('View project details', href: map_project_url(3))
      expect(email.text_part.encoded).to include('View project details: ')
      expect(email.text_part.encoded).to include(map_project_url(3))
    end

    it 'contains a link to the survey response' do
      email = ProjectMailer.needs_maintenance(survey_response.id)

      link = 'https://charitywater.fluidsurveys.com/account/surveys/10/responses/?response=20'
      expect(email.html_part.encoded).to have_link('View survey response', href: link)
      expect(email.text_part.encoded).to include('View survey response:')
      expect(email.text_part.encoded).to include(link)
    end

    it 'contains project info' do
      email = ProjectMailer.needs_maintenance(survey_response.id)

      expect(email.html_part.encoded).to include('AA.AAA.Q1.00.111.111')
      expect(email.html_part.encoded).to include('Fancy Community')
      expect(email.html_part.encoded).to match(/Reported as needing maintenance on\s+<(\w+).*?>2001-02-03<\/\1>/)

      expect(email.text_part.encoded).to include('AA.AAA.Q1.00.111.111')
      expect(email.text_part.encoded).to include('Fancy Community')
      expect(email.text_part.encoded).to include('Reported as needing maintenance on 2001-02-03')
    end
  end

  describe '#repairs_unsuccessful' do
    let(:project) do
      build(
        :project,
        :needs_maintenance,
        id: 3,
        deployment_code: 'AA.AAA.Q1.00.111.111',
        community_name: 'Fancy Community'
      )
    end

    let(:survey_response) do
      build(
        :survey_response,
        id: 6,
        fs_survey_id: 10,
        fs_response_id: 20,
        submitted_at: DateTime.strptime('2001-02-03T04:05:06+00:00', '%Y-%m-%dT%H:%M:%S%z'),
        project: project,
      )
    end

    before do
      allow(Project).to receive(:find).with(3) { project }
      allow(SurveyResponse).to receive(:find).with(6) { survey_response }
    end

    it 'sends a multipart/alternative email' do
      email = ProjectMailer.repairs_unsuccessful(survey_response.id)

      expect(email).to be_multipart
    end

    it 'has the right subject' do
      email = ProjectMailer.repairs_unsuccessful(survey_response.id)

      expect(email.subject).to eq 'Repairs at Fancy Community (AA.AAA.Q1.00.111.111) were unsuccessful'
    end

    it 'contains a link to the project page' do
      email = ProjectMailer.repairs_unsuccessful(survey_response.id)

      expect(email.html_part.encoded).to have_link('View project details', href: map_project_url(3))
      expect(email.text_part.encoded).to include('View project details: ')
      expect(email.text_part.encoded).to include(map_project_url(3))
    end

    it 'contains a link to the survey response' do
      email = ProjectMailer.repairs_unsuccessful(survey_response.id)

      link = 'https://charitywater.fluidsurveys.com/account/surveys/10/responses/?response=20'
      expect(email.html_part.encoded).to have_link('View survey response', href: link)
      expect(email.text_part.encoded).to include('View survey response:')
      expect(email.text_part.encoded).to include(link)
    end

    it 'contains project info' do
      email = ProjectMailer.repairs_unsuccessful(survey_response.id)

      expect(email.html_part.encoded).to include('AA.AAA.Q1.00.111.111')
      expect(email.html_part.encoded).to include('Fancy Community')
      expect(email.html_part.encoded).to match(/Reported as still needing maintenance on\s+<(\w+).*?>2001-02-03<\/\1>/)

      expect(email.text_part.encoded).to include('AA.AAA.Q1.00.111.111')
      expect(email.text_part.encoded).to include('Fancy Community')
      expect(email.text_part.encoded).to include('Reported as still needing maintenance on 2001-02-03')
    end
  end
end
