JsRoutes.setup do |config|
  config.namespace = 'RemoteMonitoring.routes'
  # Editing the list of routes to include?
  # Don't forget to stop your server, run `rake tmp:cache:clear`,
  # then start your server again.
  config.include = [
    /^(?:edit_)?project$/,
    /^map_project_activities$/,
    /^map_project_tickets$/,
    /^new_project_ticket$/,
    /^map_project_sensors$/,
    /^sensors_receive$/,
  ]
end
