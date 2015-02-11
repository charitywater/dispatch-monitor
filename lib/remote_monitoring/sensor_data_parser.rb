module RemoteMonitoring
  class SensorDataParser
    def initialize(encoded_data)
      @raw_data = decode_raw_data(encoded_data)
    end

    # takes a base64 encoded string of hex bytes and returns an array of those hex values converted to decimal
    def decode_raw_data(encoded_data)
      decode = Base64.decode64(encoded_data)
      decode_array = decode.unpack('H*').first.scan(/../)
      decode_integers = decode_array.map { |b| b.to_i(16) }
      @raw_data = decode_integers
    end

    def get_int(index)
      @raw_data[index] + @raw_data[index + 1] * 256
    end

    def decode_daily(chars = @raw_data)
      liters = [nil] * 24
      pad_max = [nil] * 6
      pad_min = [nil] * 6
      pad_submerged = [nil] * 6
      unknowns = 0
      offset = 0
      red_flag = 0

      for x in 0..23
        index = x * 2 + offset
        liters[x] = get_int(index) / 32 # divide by 32 because the liters value is stored in the first 11 bites (last 5 are sub-precision)
      end

      offset += 24*2

      for x in 0..5
        index = x*2 + offset
        pad_max[x] = get_int(index)
        pad_min[x] = get_int(index+12)
        pad_submerged[x] = get_int(index+24)
      end
      offset += 6 * 2 * 3
      unknowns = get_int(offset)
      offset += 2
      red_flag = chars[offset]

      {
        "liters" => liters,
        "padMax" => pad_max,
        "padMin" => pad_min,
        "padSubmerged" => pad_submerged,
        "unknowns" => unknowns,
        "redFlag" => red_flag
      }
    end

    def decode_weekly(chars = @raw_data)
      redFlag = chars[2]
      gmt_second = bcd_to_int(chars[3])
      gmt_minute = bcd_to_int(chars[4])
      gmt_hour = bcd_to_int(chars[5])
      gmt_day = bcd_to_int(chars[6])
      gmt_month = bcd_to_int(chars[7])
      gmt_year = bcd_to_int(chars[8])
      daily1 = decode_daily(chars[10..100])
      daily2 = decode_daily(chars[100..190])
      daily3 = decode_daily(chars[190..280])
      daily4 = decode_daily(chars[280..370])
      daily5 = decode_daily(chars[370..460])
      daily6 = decode_daily(chars[460..550])
      daily7 = decode_daily(chars[550..640])
      
      {
        "values" => {
          "weeklyLog" => {
            "redFlag" => redFlag,
            "GMTsecond" => gmt_second,
            "GMTminute" => gmt_minute,
            "GMThour" => gmt_hour,
            "GMTday" => gmt_day,
            "GMTmonth" => gmt_month,
            "GMTyear" => gmt_year,
            "dailyLogs" => [daily1, daily2, daily3, daily4, daily5, daily6, daily7]
          }
        }
      }
    end

    def bcd_to_int(char)
      char.to_s(16).to_i
    end
  end
end