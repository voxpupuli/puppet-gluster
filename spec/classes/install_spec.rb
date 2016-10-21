require 'spec_helper'

describe 'gluster::install', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end
      let :pre_condition do
        'require ::gluster::service'
      end
      context 'with defaults' do
        it { should compile.with_all_deps }
        case facts[:osfamily]
        when 'Redhat'
          it { should create_package('glusterfs-server') }
          it { should create_package('glusterfs-fuse') }
          it { should create_class('gluster::repo').with(version: 'LATEST') }
        when 'Debian'
          it { should create_package('glusterfs-server') }
          it { should create_package('glusterfs-client') }
          it { should create_class('gluster::repo').with(version: 'LATEST') }
        end
      end
      context 'when repo is false' do
        let :params do
          { repo: false }
        end
        it { should_not create_class('gluster::repo') }
      end
      context 'when client is false' do
        let :params do
          { client: false }
        end
        case facts[:osfamily]
        when 'Redhat'
          it { should_not create_package('glusterfs-fuse') }
        when 'Debian'
          it { should_not create_package('glusterfs-client') }
        end
      end
      context 'when server is false' do
        let :params do
          { server: false }
        end
        case facts[:osfamily]
        when 'Redhat'
          it { should_not create_package('glusterfs-server') }
        when 'Debian'
          it { should_not create_package('glusterfs-server') }
        end
      end
      context 'installing on an unsupported architecture' do
        let :facts do
          super().merge(
            architecture: 'zLinux'
          )
        end
        case facts[:osfamily]
        when 'Archlinux'
          it { should_not create_class('gluster::repo') }
        else
          it { should raise_error(Puppet::Error, %r{not yet supported}) }
        end
      end
    end
  end
end
