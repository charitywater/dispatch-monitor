class NilProgram
  def id
    nil
  end

  def projects
    Project.all
  end

  def survey_responses
    SurveyResponse.all
  end

  def tickets
    Ticket.all
  end

  def name
    ''
  end
end
