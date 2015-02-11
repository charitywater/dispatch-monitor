require 'spec_helper'

describe TimezoneHelper do
  describe '#all_country_timezones' do
    it 'formats timezones with positive offsets' do
      timezones = helper.all_country_timezones([
        TZInfo::Timezone.get('Africa/Addis_Ababa')
      ])

      expect(timezones.first).to eq [
        'Africa/Addis_Ababa (+3:00)',
        'Africa/Addis_Ababa'
      ]
    end

    it 'formats timezones with negative offsets' do
      timezones = helper.all_country_timezones([
        TZInfo::Timezone.get('America/Santo_Domingo')
      ])

      expect(timezones.first).to eq [
        'America/Santo_Domingo (-4:00)',
        'America/Santo_Domingo'
      ]
    end

    it 'formats timezones with positive double-digit hours' do
      timezones = helper.all_country_timezones([
        TZInfo::Timezone.get('Asia/Kamchatka')
      ])

      expect(timezones.first).to eq [
        'Asia/Kamchatka (+12:00)',
        'Asia/Kamchatka'
      ]
    end

    it 'formats timezones with negative double-digit hours' do
      timezones = helper.all_country_timezones([
        TZInfo::Timezone.get('Pacific/Tahiti')
      ])

      expect(timezones.first).to eq [
        'Pacific/Tahiti (-10:00)',
        'Pacific/Tahiti'
      ]
    end

    it 'returns the timezones with unusual offsets' do
      timezones = helper.all_country_timezones([
        TZInfo::Timezone.get('Asia/Kathmandu')
      ])

      expect(timezones.first).to eq [
        'Asia/Kathmandu (+5:45)',
        'Asia/Kathmandu'
      ]
    end

    it 'returns utc as the last element' do
      timezones = helper.all_country_timezones([])
      expect(timezones.last).to eq ['UTC (+0:00)', 'UTC']
    end
  end
end
