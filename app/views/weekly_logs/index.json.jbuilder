json.array!(@weekly_logs) do |weekly_log|
  json.extract! weekly_log, :id, :show, :index
  json.url weekly_log_url(weekly_log, format: :json)
end
