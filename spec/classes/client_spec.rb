require 'spec_helper'

describe 'gluster::client', :type => :class do
  describe 'when installing on Red Hat Enterprise Linux' do
    let :facts do
      {
        :osfamily => 'RedHat',
        :architecture => 'x86_64',
      }
    end
    context 'when using all default values' do
      it 'should include gluster::install' do
        should create_class('gluster::install').with(
          :repo           => true,
          :client_package => 'glusterfs-fuse',
          :version        => 'LATEST',
        )
      end
    end
    context 'when a version number is specified' do
      let(:params) { { :version => '3.6.1' } }
      it 'should include gluster::install with version 3.6.1' do
        should create_class('gluster::install').with(
          :repo           => true,
          :client_package => 'glusterfs-fuse',
          :version        => '3.6.1',
        )
      end
    end
    context 'when repo is false' do
      let(:params) { { :repo => false } }
      it 'should include gluster::install with repo=>false' do
        should create_class('gluster::install').with(
          :repo           => false,
          :client_package => 'glusterfs-fuse',
          :version        => 'LATEST',
        )
      end
    end
  end
end
