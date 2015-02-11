module RemoteMonitoring
  module Constants
    def self.deployment_code_regex
      @deployment_code_regex ||= /\A
      [A-Z]{2}            # country
      \.[A-Z]{3}          # partner
      \.[A-Z][1-4]        # quarter
      \.\d{2}             # year
      \.\d{2,3}           # grant deployment code
      \.\d{2,3}           # deployment code
      (?:\.\d{2,3})*      # optional sub-deployment code
      \Z/ix
    end

    def self.grant_deployment_code_regex
      @grant_deployment_code_regex ||= /\A
      [A-Z]{2}            # country
      \.[A-Z]{3}          # partner
      \.[A-Z][1-4]        # quarter
      \.\d{2}             # year
      \.\d{2,3}           # grant deployment code
      \Z/ix
    end
  end
end
