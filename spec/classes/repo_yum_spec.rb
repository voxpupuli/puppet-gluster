require 'spec_helper'

describe 'gluster::repo::yum', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      context 'with all defaults' do
        it { should contain_class('gluster::repo::yum') }
        it { should compile.with_all_deps }
        it 'installs' do
          should_not create_package('yum-plugin-priorities')
          should create_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub')
          should create_yumrepo('glusterfs-x86_64').with(
            enabled: 1,
            baseurl: "https://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/epel-#{facts[:operatingsystemmajrelease]}/x86_64/",
            gpgcheck: 1,
            gpgkey: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub'
          )
        end
      end
      context 'bogus version' do
        let :params do
          {
            version: 'foobar'
          }
        end
        it 'does not install' do
          expect do
            should create_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub')
          end.to raise_error(Puppet::Error, %r{doesn't make sense!})
        end
      end
      context 'unsupported architecture' do
        let :facts do
          super().merge(
            architecture: 'zLinux'
          )
        end
        it 'does not install' do
          expect do
            should create_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub')
          end.to raise_error(Puppet::Error, %r{not yet supported})
        end
      end
      context 'latest Gluster with priority' do
        let :params do
          {
            priority: '50'
          }
        end
        it 'installs' do
          should create_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub')
          should create_package('yum-plugin-priorities')
          should create_yumrepo('glusterfs-x86_64').with(
            enabled: 1,
            baseurl: "https://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/epel-#{facts[:operatingsystemmajrelease]}/x86_64/",
            gpgcheck: 1,
            gpgkey: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub',
            priority: '50'
          )
        end
      end
    end
  end
end
