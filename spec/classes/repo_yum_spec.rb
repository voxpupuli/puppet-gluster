require 'spec_helper'

describe 'gluster::repo::yum', :type => :class do
  describe 'version not specified' do
    it 'should not install' do
      expect do
        should create_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub')
      end.to raise_error(Puppet::Error, /Version not specified/)
    end
  end
  describe 'bogus version' do
    let(:params) { { :version => 'foobar', } }
    it 'should not install' do
      expect do
        should create_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub')
      end.to raise_error(Puppet::Error, /doesn't make sense!/)
    end
  end
  describe 'unsupported architecture' do
    let(:facts) { { :architecture => 'zLinux', } }
    let(:params) { { :version => 'LATEST', } }
    it 'should not install' do
      expect do
        should create_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub')
      end.to raise_error(Puppet::Error, /not yet supported/)
    end
  end
  describe 'Red Hat Enterprise Linux' do
    context 'latest Gluster on RHEL 6 x86_64' do
      let :facts do
        {
          :architecture => 'x86_64',
          :operatingsystemmajrelease => '6',
        }
      end
      let :params do
        {
          :version => 'LATEST',
          :repo_key_path => '/etc/pki/rpm-gpg/',
          :repo_key_name => 'RPM-GPG-KEY-gluster.pub',
          :repo_key_source => 'puppet:///modules/gluster/RPM-GPG-KEY-gluster.pub',
        }
      end
      it 'should install' do
        should_not create_package('yum-plugin-priorities')
        should create_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub')
        should create_yumrepo('glusterfs-x86_64').with(
          :enabled  => 1,
          :baseurl  => 'https://download.gluster.org/pub/gluster/glusterfs/LATEST/RHEL/epel-6/x86_64/',
          :gpgcheck => 1,
          :gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub',
        )
      end
    end
    context 'latest Gluster on RHEL 6 x86_64 with priority' do
      let :facts do
        {
          :architecture => 'x86_64',
          :operatingsystemmajrelease => '6',
        }
      end
      let :params do
        {
          :version         => 'LATEST',
          :repo_key_path   => '/etc/pki/rpm-gpg/',
          :repo_key_name   => 'RPM-GPG-KEY-gluster.pub',
          :repo_key_source => 'puppet:///modules/gluster/RPM-GPG-KEY-gluster.pub',
          :priority        => '50',
        }
      end
      it 'should install' do
        should create_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub')
        should create_package('yum-plugin-priorities')
        should create_yumrepo('glusterfs-x86_64').with(
          :enabled  => 1,
          :baseurl  => 'https://download.gluster.org/pub/gluster/glusterfs/LATEST/RHEL/epel-6/x86_64/',
          :gpgcheck => 1,
          :gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub',
          :priority => '50',
        )
      end
    end
  end
end
