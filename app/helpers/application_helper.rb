module ApplicationHelper
  def current_path
    request.env['PATH_INFO']
  end

  def active_class(path)
    current_path == path ? 'active' : ''
  end

  def admin_active_class
    admin_path? ? 'active' : ''
  end

  def admin_path?
    [
      admin_accounts_path,
      edit_admin_application_settings_path,
      admin_email_subscriptions_path,
    ].include?(current_path)
  end

  def sortable(column, filter_form)
    title ||= column.titleize
    css_class = column.parameterize.underscore == filter_form.sort_column ? "current #{filter_form.sort_direction}" : nil
    direction = filter_form.sort_direction == "asc" ? "desc" : "asc"

    params = {}
    params["filters"] = {}
    params["filters"]["program_id"] = filter_form.program_id
    params["filters"]["status"] = filter_form.status
    params["filters"]["page"] = filter_form.page
    params["filters"]["sort_column"] = filter_form.sort_column
    params["filters"]["sort_direction"] = direction

    link_to title, params, {:class => css_class, :remote => true}
  end
end
