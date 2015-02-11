require 'spec_helper'

describe EnumHelper do
  describe '#enum_to_select_options_array' do
    let(:statuses) do
      {
        'one' => 1,
        'two' => 2,
        'three' => 3,
      }
    end

    it 'returns an array of titleized string pairs' do
      expect(helper.enum_to_select_options_array(statuses)).to eq [
        %w(One one), %w(Two two), %w(Three three)
      ]
    end
  end
end
