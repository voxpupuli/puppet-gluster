require 'spec_helper'

describe 'gluster::service', type: :class do
  it 'should start the service' do
    should create_service('glusterd')
  end
end
