module Import
  class Project
    include ActiveModel::Model

    attr_accessor :import_codes

    validates :import_codes, presence: true
    validate  :validate_import_codes

    def validate_import_codes
      all_import_codes.each do |c|
        errors[:import_codes] << "Invalid code: #{c}" unless well_formed?(c)
      end
    end

    def deployment_codes
      all_import_codes.select { |c| c.split('.').count > 5 }
    end

    def grant_deployment_codes
      all_import_codes.select { |c| c.split('.').count == 5 }
    end

    private

    def all_import_codes
      import_codes.to_s.split
    end

    def well_formed?(code)
      import_code_regexes.any? { |r| r.match(code) }
    end

    def import_code_regexes
      @import_code_regexes ||= [
        RemoteMonitoring::Constants::grant_deployment_code_regex,
        RemoteMonitoring::Constants::deployment_code_regex,
      ]
    end
  end
end
