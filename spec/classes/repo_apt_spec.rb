require 'spec_helper'

describe 'gluster::repo::apt', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let :pre_condition do
        'require ::gluster::params'
      end
      case facts[:osfamily]
      when 'Debian'
        context 'with all defaults' do
          it { should contain_class('gluster::repo::apt') }
          it { should compile.with_all_deps }
          it 'installs' do
            should contain_apt__source('glusterfs-LATEST').with(
              :repos    => 'main',
              :release  => "#{facts[:lsbdistcodename]}",
              :location => "http://download.gluster.org/pub/gluster/glusterfs/LATEST/Debian/#{facts[:lsbdistcodename]}/apt/"
            )
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
              priority: '700'
            }
          end
          it 'installs' do
            should contain_apt__source('glusterfs-LATEST').with(
              :repos    => 'main',
              :release  => "#{facts[:lsbdistcodename]}",
              :location => "http://download.gluster.org/pub/gluster/glusterfs/LATEST/Debian/#{facts[:lsbdistcodename]}/apt/",
              :pin      => '700'
            )
          end
        end
      end
    end
  end
end
