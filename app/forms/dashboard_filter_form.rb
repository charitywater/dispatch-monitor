class DashboardFilterForm < FilterForm
  def days=(days)
    days = days.to_s.strip.to_i
    @days = days < 1 ? 30 : days
  end

  def days
    @days || 30
  end

  def since
    days.days.ago
  end

  private

  def attributes
    {
      program_id: program_id,
      days: days,
    }
  end
end
