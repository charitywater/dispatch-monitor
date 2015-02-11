require 'spec_helper'

module Import
  describe ProjectPolicy do
    let(:policy) { ProjectPolicy.new(account) }

    it_behaves_like 'an admin policy'
  end
end
