class ProjectPresenter < Presenter
  def title
    "#{community_name} – #{country}"
  end

  def country
    project.country.name
  end

  def partner
    project.partner.name
  end

  def status_tag
    content_tag(:span, status.titleize, class: "project-status #{status}")
  end

  def region
    project.region || 'N/A'
  end

  def district
    project.district || 'N/A'
  end

  def site_name
    project.site_name || 'N/A'
  end

  def allows_new_ticket?
    %i(unknown flowing).include?(project.status.to_sym)
  end

  def has_sensor?
    sensor.present?
  end

  def as_json(*_)
    {
      id: id,
      latitude: latitude,
      longitude: longitude,
      title: title,
      country: country,
      community_name: community_name,
      inventory_type: inventory_type,
      status: status,
      beneficiaries: beneficiaries,
      location_type: location_type,
      partner: partner,
      deployment_code: deployment_code,
      completion_date: completion_date,
      contact_name: contact_name,
      contact_email: contact_email,
      contact_phone_numbers: contact_phone_numbers,
      has_sensor: has_sensor?,
    }
  end

  def self.policy_class
    ProjectPolicy
  end

  private

  alias_method :project, :__getobj__
end
