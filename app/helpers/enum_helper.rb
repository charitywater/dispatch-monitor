module EnumHelper
  def enum_to_select_options_array(enum_hash)
    enum_hash.keys.map { |e| [e.titleize, e] }
  end
end
