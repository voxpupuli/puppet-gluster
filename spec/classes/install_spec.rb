require 'spec_helper'

describe 'gluster::install', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      context 'with defaults' do
        it { should compile.with_all_deps }
        it 'should create gluster::repo' do
          should create_class('gluster::repo').with(
            version: 'LATEST',
          )
        end
        it 'should install glusterfs-fuse package' do
          should create_package('glusterfs-fuse')
        end
        it 'should install glusterfs-server' do
          should create_package('glusterfs-server')
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
      context 'when client is false' do
        let :params do
          { client: false }
        end
        it 'should not install glusterfs-fuse package' do
          should_not create_package('glusterfs-fuse')
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
      context 'installing on an unsupported architecture' do
        let :facts do
          super().merge(
            { architecture: 'zLinux' }
          )
        end
        it 'should not install' do
          expect {
            should create_class('gluster::repo')
          }.to raise_error(Puppet::Error, /not yet supported/)
        end
      end
    end
  end
end
