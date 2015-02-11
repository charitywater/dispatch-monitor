module TurnOffPagination
  def turn_off_pagination
    Kaminari.configure do |config|
      old_default_per_page = config.default_per_page
      config.default_per_page = 10000

      yield

      config.default_per_page = old_default_per_page
    end
  end
end

RSpec.configure do |config|
  config.include TurnOffPagination, type: :feature
end
