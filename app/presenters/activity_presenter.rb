class ActivityPresenter < Presenter
  def happened_at
    l(activity.happened_at, format: :date)
  end

  def url
    if data.present? &&
      data['fs_survey_id'].present? &&
      data['fs_response_id'].present?
      SurveyResponse.fluid_surveys_url(
        data['fs_survey_id'],
        data['fs_response_id'],
      )
    end
  end

  def data
    return if activity.data.blank?

    data = activity.data.clone

    if activity.data['status']
      data['status'] = Project.statuses.invert[activity.data['status']]
    end

    data
  end

  def manually_created_by
    if activity.manually_created_by
      AccountPresenter.new(activity.manually_created_by)
    end
  end

  def as_json(*_)
    {
      type: activity_type,
      happened_at: happened_at,
      url: url,
      data: data,
      manually_created_by: manually_created_by.as_json,
      generated_by_sensor: generated_by_sensor?,
    }
  end

  private

  alias_method :activity, :__getobj__
end
