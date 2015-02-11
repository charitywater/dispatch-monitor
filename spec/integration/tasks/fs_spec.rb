require 'spec_helper'

describe 'rake fs:<tasks>', :vcr do
  before do
    %w(webhook webhooks subscribe unsubscribe).each do |task|
      Rake::Task["fs:#{task}"].reenable
    end

    allow(Fs).to receive(:puts)
  end

  it 'subscribes to and unsubscribes from FS' do
    Rake::Task['fs:webhook'].invoke
    expect(Fs).not_to have_received(:puts).with(/example\.com/)

    Rake::Task['fs:subscribe'].invoke('http://example.com?subscribe', :test_source_observation_v1)
    expect(Fs).to have_received(:puts).with(/Subscription successful/)

    Rake::Task['fs:webhooks'].reenable
    Rake::Task['fs:webhooks'].invoke
    expect(Fs).to have_received(:puts).with(/example\.com\?subscribe.*id: 68883/m).once

    Rake::Task['fs:unsubscribe'].invoke('http://example.com?subscribe')
    expect(Fs).to have_received(:puts).with(/Unsubscribe successful/)

    Rake::Task['fs:webhooks'].reenable
    Rake::Task['fs:webhooks'].invoke
    expect(Fs).to have_received(:puts).with(/example\.com\?subscribe.*id: 68883/m).once
  end
end
