require 'spec_helper'

describe 'gluster::repo::yum', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} with all defaults" do
      let(:facts) do
        facts
      end
      it 'should install' do
        should_not create_package('yum-plugin-priorities')
        should create_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub')
        should create_yumrepo('glusterfs-x86_64').with(
          enabled: 1,
          baseurl: 'https://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/epel-6/x86_64/',
          gpgcheck: 1,
          gpgkey: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub',
        )
      end
    end
    describe 'bogus version' do
      let :params do { version: 'foobar', } end
      it 'should not install' do
        expect {
          should create_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub')
        }.to raise_error(Puppet::Error, /doesn't make sense!/)
      end
    end
    describe 'unsupported architecture' do
      let :facts do { architecture: 'zLinux', } end
      it 'should not install' do
        expect {
          should create_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub')
        }.to raise_error(Puppet::Error, /not yet supported/)
      end
    end
    context 'latest Gluster with priority' do
      let :params do
        {
          priority: '50',
        }
      end
      it 'should install' do
        should create_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub')
        should create_package('yum-plugin-priorities')
        should create_yumrepo('glusterfs-x86_64').with(
          enabled: 1,
          baseurl: 'https://download.gluster.org/pub/gluster/glusterfs/LATEST/EPEL.repo/epel-6/x86_64/',
          gpgcheck: 1,
          gpgkey: 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub',
          priority: '50',
        )
      end
    end
  end
end
