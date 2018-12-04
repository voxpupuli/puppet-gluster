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
          it { is_expected.to contain_class('gluster::repo::apt') }
          it { is_expected.to compile.with_all_deps }
          it 'installs' do
            is_expected.to contain_apt__source('glusterfs-LATEST').with(
              repos: 'main',
              release: facts[:lsbdistcodename].to_s,
              location: "http://download.gluster.org/pub/gluster/glusterfs/3.12/LATEST/Debian/#{facts[:lsbdistcodename]}/#{facts[:architecture]}/apt/"
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
              is_expected.to create_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-gluster.pub')
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
            is_expected.to contain_apt__source('glusterfs-LATEST').with(
              repos: 'main',
              release: facts[:lsbdistcodename].to_s,
              location: "http://download.gluster.org/pub/gluster/glusterfs/3.12/LATEST/Debian/#{facts[:lsbdistcodename]}/#{facts[:architecture]}/apt/",
              pin: '700'
            )
          end
        end

        context 'Specific Gluster release 4.1' do
          let :params do
            {
              release: '4.1'
            }
          end

          it 'installs' do
            is_expected.to contain_apt__source('glusterfs-LATEST').with(
              repos: 'main',
              release: facts[:lsbdistcodename].to_s,
              key: {
                'id' => 'EED3351AFD72E5437C050F0388F6CDEE78FA6D97',
                'key_source' => 'https://download.gluster.org/pub/gluster/glusterfs/4.1/rsa.pub'
              },
              location: "http://download.gluster.org/pub/gluster/glusterfs/4.1/LATEST/Debian/#{facts[:lsbdistcodename]}/amd64/apt/"
            )
          end
        end

        context 'Specific Gluster release 3.9' do
          let :params do
            {
              release: '3.9'
            }
          end

          it 'installs' do
            is_expected.to contain_apt__source('glusterfs-LATEST').with(
              repos: 'main',
              release: facts[:lsbdistcodename].to_s,
              key: {
                'id' => '849512C2CA648EF425048F55C883F50CB2289A17',
                'key_source' => 'https://download.gluster.org/pub/gluster/glusterfs/3.9/rsa.pub'
              },
              location: "http://download.gluster.org/pub/gluster/glusterfs/3.9/LATEST/Debian/#{facts[:lsbdistcodename]}/apt/"
            )
          end
        end

        context 'Specific Gluster release 3.8' do
          let :params do
            {
              release: '3.8'
            }
          end

          it 'installs' do
            is_expected.to contain_apt__source('glusterfs-LATEST').with(
              repos: 'main',
              release: facts[:lsbdistcodename].to_s,
              key: {
                'id' => 'A4703C37D3F4DE7F1819E980FE79BB52D5DC52DC',
                'key_source' => 'https://download.gluster.org/pub/gluster/glusterfs/3.8/LATEST/rsa.pub'
              },
              location: "http://download.gluster.org/pub/gluster/glusterfs/3.8/LATEST/Debian/#{facts[:lsbdistcodename]}/apt/"
            )
          end
        end

      end
    end
  end
end
