xml.stuResponseMsg(
  correlationID: @message_id,
  deliveryTimeStamp: (l @delivered_at, format: :globalstar),
  messageID: @delivered_at.to_i,
  'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xsi:noNamespaceSchemaLocation' => 'http://cody.glpconnect.com/XSD/StuResponse_Rev1_0.xsd',
) do
  xml.state 'pass'
  xml.stateMessage 'OK'
end
