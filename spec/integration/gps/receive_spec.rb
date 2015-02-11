require 'spec_helper'

describe 'GPS receive endpoint', :integration do
  let(:message_id) { '930d23f0567710058db5ffb99d435d16' }
  let(:xml_request) do
    <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <stuMessages
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:noNamespaceSchemaLocation="http://cody.glpconnect.com/XSD/StuMessage_Rev1_0_1.xsd"
       timeStamp="11/06/2014 15:59:11 GMT"
       messageID="#{message_id}"
      >
        <stuMessage>
          <esn>0-1227749</esn>
          <unixTime>1402502351</unixTime>
          <gps>N</gps>
          <payload length="9" source="pc" encoding="hex">0x0014266C1C21AF0A50</payload>
        </stuMessage>
        <stuMessage>
          <esn>0-1227980</esn>
          <unixTime>1402502361</unixTime>
          <gps>N</gps>
          <payload length="9" source="pc" encoding="hex">0x0014266C1C21AF0A50</payload>
        </stuMessage>
        <stuMessage>
          <esn>0-invalid-esn</esn>
          <unixTime>1402502371</unixTime>
          <gps>N</gps>
          <payload length="9" source="pc" encoding="hex">0x0014266C1C21AF0A50</payload>
        </stuMessage>
      </stuMessages>
    XML
  end
  let(:url) { ENV['WAZI_GPS_URL'] }

  let(:rig1) do
    payload('1227749', '2014/06/11 15:59:11')
  end

  let(:rig2) do
    payload('1227980', '2014/06/11 15:59:21')
  end

  let(:not_a_rig) do
    payload('invalid-esn', '2014/06/11 15:59:31')
  end

  let(:importer) { double(:importer) }

  def payload(esn, unix_time)
    %r|#{unix_time}	#{esn}	xx	xx	xx	#{esn}	xx	#{unix_time}	Location	xx	xx	xx	xx	39.560030	14.168029	xx	xx	xx	xx	xx	High|
  end

  before do
    Timecop.travel DateTime.strptime('2001-02-03T04:05:06 GMT', '%Y-%m-%dT%H:%M:%S %Z')

    stub_request(:post, url).to_return(
      status: 200,
      body: 'pass'
    )
  end

  after do
    Timecop.return
  end

  it 'sends the rig updates to WAZI and acknowledges the request from GlobalStar' do
    post '/gps/receive', xml_request

    expect(WebMock).to have_requested(:post, url).with(body: rig1)
    expect(WebMock).to have_requested(:post, url).with(body: rig2)
    expect(WebMock).not_to have_requested(:post, url).with(body: not_a_rig)

    parsed_response = Nokogiri::XML(response.body)

    expect(parsed_response.at_xpath('/stuResponseMsg')['correlationID']).to eq(message_id)
    expect(parsed_response.at_xpath('/stuResponseMsg')['deliveryTimeStamp']).to eq('03/02/2001 04:05:06 GMT')
    expect(parsed_response.at_xpath('/stuResponseMsg')['messageID']).to eq('981173106')
    expect(parsed_response.at_xpath('/stuResponseMsg/state').text).to eq('pass')
    expect(parsed_response.at_xpath('/stuResponseMsg/stateMessage').text).to eq('OK')
  end
end
