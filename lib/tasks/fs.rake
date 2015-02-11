require 'pp'

class Fs
  def self.puts(*args)
    super
  end

  def self.client
    FluidSurveys::Client.new
  end
end

namespace :fs do
  desc 'Subscribe to FluidSurveys webhook'
  task :subscribe, [:callback_url, :survey_type] => :environment do |t, args|
    response = Fs.client.subscribe_to_webhook(
      callback_url: args.callback_url,
      survey_type: args.survey_type,
    )
    if response.code == 201
      Fs.puts 'Subscription successful'
    elsif response.code == 409
      Fs.puts 'Warning: Subscription already exists'
    else
      Fs.puts "Error: Subscription failed with response #{response.code}"
    end
  end

  desc 'Unsubscribe from FluidSurveys webhook'
  task :unsubscribe, [:callback_url] => :environment do |t, args|
    response = Fs.client.unsubscribe_from_webhook(args.callback_url)
    if response.code == 200
      Fs.puts 'Unsubscribe successful'
    else
      Fs.puts "Error: Unsubscribe failed with response #{response.code}"
    end
  end

  desc 'List FluidSurveys webhook subscriptions'
  task :webhooks => :environment do |t|
    Fs.puts(Fs.client.webhooks.to_yaml)
  end
  task webhook: :webhooks
end
