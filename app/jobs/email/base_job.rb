module Email
  class BaseJob < Job
    def self.queue
      :email
    end

    def self.perform(*args)
      email(*args).deliver
    end
  end
end
