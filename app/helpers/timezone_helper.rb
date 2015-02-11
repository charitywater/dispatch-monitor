module TimezoneHelper
  def all_country_timezones(timezones = TZInfo::Timezone.all_country_zones)
    (timezones + [utc]).sort.map do |tz|
      ["#{tz.identifier} (#{offset(tz)})", tz.identifier]
    end
  end

  private

  def offset(tz)
    sprintf(offset_format, *(tz.current_period.utc_total_offset / 60).divmod(60))
  end

  def offset_format
    '%+i:%02i'
  end

  def utc
    @utc ||= TZInfo::Timezone.get('UTC')
  end
end
