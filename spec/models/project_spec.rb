require 'spec_helper'

describe Project do
  let(:project) { Project.new }

  describe 'validations' do
    specify do
      expect(project).to validate_presence_of(:deployment_code)
    end

    specify do
      expect(project).to validate_presence_of(:wazi_id)
    end

    specify do
      create(:project)

      expect(project).to validate_uniqueness_of(:wazi_id)
    end

    specify do
      expect(project).to validate_presence_of(:status)
    end

    specify do
      expect(project).to validate_presence_of(:program_id)
    end

    specify do
      expect(project).to validate_numericality_of(:latitude)
        .is_greater_than_or_equal_to(-90.0)
        .is_less_than_or_equal_to(90.0)
    end

    specify do
      expect(project).to validate_numericality_of(:longitude)
        .is_greater_than_or_equal_to(-180.0)
        .is_less_than_or_equal_to(180.0)
    end

    specify do
      expect(project).to validate_numericality_of(:beneficiaries)
        .only_integer
        .allow_nil
    end

    it 'stores status as an enum' do
      [:unknown, :needs_maintenance, :flowing, :inactive, :needs_visit].each { |s| project.status = s }

      expect { project.status = :whatever }.to raise_error
    end

    describe 'deployment_code' do
      it 'does not match the invalid tests' do
        expect(project).not_to allow_value(
          'MZ.WVI.Q4.13.149',
          'MOZ.WVI.Q4.13.149.012',
          'MZ.WV.Q4.13.149.012',
          'MZ.WVI.Q4.13.XXX.070',
        ).for(:deployment_code)
      end

      it 'does match the valid tests' do
        expect(project).to allow_value(
          'MZ.WVI.Q4.13.149.001',
          'MZ.WVI.Q4.13.149.01',
          'Mz.WVI.Q4.13.149.001',
          'MZ.WVI.Q4.13.149.002.003',
          'MZ.WVI.Q4.13.149.02.003',
          'MZ.WVI.Q4.13.149.002.03',
          'MZ.WVI.Q4.13.149.02.03',
        ).for(:deployment_code)
      end
    end
  end

  describe 'associations' do
    specify do
      expect(project).to belong_to(:program)
    end

    specify do
      expect(project).to have_one(:partner).through(:program)
    end

    specify do
      expect(project).to have_one(:country).through(:program)
    end

    specify do
      expect(project).to have_many(:activities).dependent(:destroy)
    end

    specify do
      expect(project).to have_one(:sensor).dependent(:destroy)
    end

    specify do
      expect(project).to have_many(:survey_responses).dependent(:destroy)
    end

    specify do
      expect(project).to have_many(:tickets)
    end
  end

  describe '.within_bounds' do
    let!(:near) { create(:project, latitude: 25, longitude: 52) }
    let!(:outside1) { create(:project, latitude: 19.9, longitude: 52.0) }
    let!(:outside2) { create(:project, latitude: 30.1, longitude: 52.0) }
    let!(:outside3) { create(:project, latitude: 25.0, longitude: 49.9) }
    let!(:outside4) { create(:project, latitude: 25.0, longitude: 60.1) }

    it 'only returns projects within the bounds' do
      result = Project.within_bounds(20, 50, 30, 60)

      expect(result).to eq([near])
    end
  end

  describe '.bounds' do
    context 'when there are projects' do
      before do
        create(:project, latitude: 19.9, longitude: 52.0)
        create(:project, latitude: 30.1, longitude: 52.0)
        create(:project, latitude: 25.0, longitude: 49.9)
        create(:project, latitude: 25.0, longitude: 60.1)
      end

      it 'returns [lat_lo, lng_lo, lat_hi, lng_hi]' do
        expect(Project.bounds).to eq([19.9, 49.9, 30.1, 60.1])
      end
    end

    context 'when there are no projects' do
      it 'returns the world' do
        expect(Project.bounds).to eq([-90, -180, 90, 180])
      end
    end
  end

  describe '#status_changed_to?' do
    let!(:project) { create :project, :flowing }

    specify do
      project.reload.needs_maintenance!

      expect(project.status_changed_to?(:needs_maintenance)).to be true
      expect(project.status_changed_to?(:needs_visit)).to be false
    end

    specify do
      project.reload.needs_visit!

      expect(project.status_changed_to?(:needs_visit)).to be true
      expect(project.status_changed_to?(:inactive)).to be false
    end

    it 'requires the status to actually change' do
      project.reload.flowing!

      expect(project.status_changed_to?(:flowing)).to be false
    end
  end

  describe '#contact_phone_numbers' do
    context 'when there are phone numbers' do
      before do
        project.contact_phone_numbers = ['+1 234 567 8900']
      end

      it 'returns the array of phone numbers' do
        expect(project.contact_phone_numbers).to eq ['+1 234 567 8900']
      end
    end

    context 'when there are no phone numbers' do
      before do
        project.contact_phone_numbers = nil
      end

      it 'returns an empty array' do
        expect(project.contact_phone_numbers).to eq []
      end
    end
  end

  describe '#sensor_timezone_offset' do
    before do
      Timecop.freeze

      @program = create(
        :program,
        country: create(:country, name: "Ethiopia"),
        partner: create(:partner, name: 'Fancy Partner'),
      )

      @project = create(
        :project,
        :flowing,
        program: @program,
        deployment_code: 'FA.NCY.Q1.01.001.001',
        region: 'Fancy Region',
        district: 'Fancy District',
        community_name: 'Fancy Community',
        site_name: 'Fancy Site',
        completion_date: '1950-01-01',
        latitude: 40.71,
        longitude: -74.01
      )

      response_body = {
         "dstOffset" => 0,
         "rawOffset" => -18000,
         "status" => "OK",
         "timeZoneId" => "America/New_York",
         "timeZoneName" => "Eastern Standard Time"
      }

      stub_request(:get, "https://maps.googleapis.com/maps/api/timezone/json?key&location=#{@project.latitude},#{@project.longitude}&timestamp=#{Time.zone.now.to_i}").with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Host'=>'maps.googleapis.com', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => response_body.to_json, :headers => {})
    end

    after do
      Timecop.return
    end

    it 'returns the timezone offset' do
      expect(@project.sensor_timezone_offset).to eq 19
    end
  end
end
