require 'spec_helper'

describe 'gluster::install', type: :class do
  describe 'installing on an unsupported architecture' do
    let :facts do
      {
        architecture: 'zLinux',
        osfamily: 'Windows',
      }
    end
    it 'should not install' do
      expect {
        should create_class('gluster::repo')
      }.to raise_error(Puppet::Error, /not yet supported/)
    end
  end
  describe 'installing on Red Hat Enterprise Linux' do
    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystem: 'RedHat',
        operatingsystemmajrelease: '6',
        architecture: 'x86_64',
      }
    end
    context 'when repo is true' do
      let :params do
        { repo: true }
      end
      it 'should create gluster::repo' do
        should create_class('gluster::repo').with(
          version: 'LATEST',
        )
      end
    end
    context 'when repo is false' do
      let :params do
        { repo: false }
      end
      it 'should not create gluster::repo' do
        should_not create_class('gluster::repo')
      end
    end
    context 'when client is true' do
      let :params do
        { client: true }
      end
      it 'should install glusterfs-fuse package' do
        should create_package('glusterfs-fuse')
      end
    end
    context 'when client is false' do
      let :params do
        { client: false }
      end
      it 'should not install glusterfs-fuse package' do
        should_not create_package('glusterfs-fuse')
      end
    end
    context 'when server is true' do
      let :params do
        { server: true }
      end
      it 'should install glusterfs-server' do
        should create_package('glusterfs-server')
      end
    end
    context 'when server is false' do
      let :params do
        { server: false }
      end
      it 'should not install glusterfs-server' do
        should_not create_package('glusterfs-server')
      end
    end
  end
end
