class HttpClient
  include HTTParty
  logger Rails.logger, :info, :curl

  def get(*args)
    self.class.get(*args)
  end

  def post(*args)
    self.class.post(*args)
  end
end
