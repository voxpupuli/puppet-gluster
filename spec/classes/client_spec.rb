require 'spec_helper'

describe 'gluster::client', :type => :class do
  let :facts do
    {
      :osfamily => 'RedHat',
      :architecture => 'x86_64',
    }
  end
  let :params do { :version => 'LATEST', } end
  it 'should include gluster::install' do
    should create_class('gluster::install')
  end
end
