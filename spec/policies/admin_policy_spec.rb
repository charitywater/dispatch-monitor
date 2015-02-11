require 'spec_helper'

describe AdminPolicy do
  let(:policy) { AdminPolicy.new(account) }

  it_behaves_like 'an admin policy'
end
