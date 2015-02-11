class GenerateProgramsAndCountriesForProjects < ActiveRecord::Migration
  class Partner < ActiveRecord::Base
  end

  class Country < ActiveRecord::Base
  end

  class Program < ActiveRecord::Base
    belongs_to :partner
    belongs_to :country
  end

  class Project < ActiveRecord::Base
  end

  def up
    [Partner, Country, Program, Project].each(&:reset_column_information)

    Partner.all.each do |partner|
      country = Country.find_or_create_by(name: partner.country)
      program = Program.find_or_create_by(country_id: country.id, partner_id: partner.id)
      Project.where(partner_id: partner.id).update_all(program_id: program.id)
    end
  end

  def down
    [Partner, Country, Program, Project].each(&:reset_column_information)

    Program.all.each do |program|
      partner = Partner.find_or_create_by(name: program.partner.name)
      partner.update(country: program.country.name)

      Project.where(program_id: program.id).update_all(partner_id: partner.id)
    end
  end
end
