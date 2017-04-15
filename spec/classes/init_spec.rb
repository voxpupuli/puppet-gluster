require 'spec_helper'

describe 'gluster', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      case facts[:osfamily]
      when 'Redhat'
        context 'with all defaults' do
          it { is_expected.to contain_class('gluster') }
          it { is_expected.to contain_class('gluster::params') }
          it { is_expected.to compile.with_all_deps }

          it 'includes classes' do
            is_expected.to contain_class('gluster::install')
            is_expected.to contain_class('gluster::service')
          end
          it 'creates gluster::install' do
            is_expected.to create_class('gluster::install').with(
              server: true,
              server_package: 'glusterfs',
              client: true,
              client_package: 'glusterfs-fuse',
              version: 'LATEST',
              repo: true
            )
          end
          it 'manages the Gluster service' do
            is_expected.to create_class('gluster::service').with(
              ensure: true
            )
          end
        end
        context 'specific version and package names defined' do
          let :params do
            {
              server_package: 'custom-gluster-server',
              client_package: 'custom-gluster-client',
              version: '3.1.4',
              repo: false
            }
          end

          it 'creates gluster::install' do
            is_expected.to create_class('gluster::install').with(
              server: true,
              server_package: 'custom-gluster-server',
              client: true,
              client_package: 'custom-gluster-client',
              version: '3.1.4',
              repo: false
            )
          end
          it 'manages the Gluster service' do
            is_expected.to create_class('gluster::service').with(
              ensure: true
            )
          end
          it 'installs custom-gluster-client and custom-gluster-server' do
            is_expected.to create_package('custom-gluster-client')
            is_expected.to create_package('custom-gluster-server')
          end
        end
      when 'Debian'
        context 'with all defaults' do
          it { is_expected.to contain_class('gluster') }
          it { is_expected.to contain_class('gluster::params') }
          it { is_expected.to compile.with_all_deps }

          it 'includes classes' do
            is_expected.to contain_class('gluster::install')
            is_expected.to contain_class('gluster::service')
          end
          it 'creates gluster::install' do
            is_expected.to create_class('gluster::install').with(
              server: true,
              server_package: 'glusterfs-server',
              client: true,
              client_package: 'glusterfs-client',
              version: 'LATEST',
              repo: true
            )
          end
          it 'manages the Gluster service' do
            is_expected.to create_class('gluster::service').with(
              ensure: true
            )
          end
        end
        context 'specific version and package names defined' do
          let :params do
            {
              server_package: 'custom-gluster-server',
              client_package: 'custom-gluster-client',
              version: '3.1.4',
              repo: false
            }
          end

          it 'creates gluster::install' do
            is_expected.to create_class('gluster::install').with(
              server: true,
              server_package: 'custom-gluster-server',
              client: true,
              client_package: 'custom-gluster-client',
              version: '3.1.4',
              repo: false
            )
          end
          it 'manages the Gluster service' do
            is_expected.to create_class('gluster::service').with(
              ensure: true
            )
          end
          it 'installs custom-gluster-client and custom-gluster-server' do
            is_expected.to create_package('custom-gluster-client')
            is_expected.to create_package('custom-gluster-server')
          end
        end
      end

      context 'when volumes defined' do
        let :facts do
          super().merge(
            gluster_binary: '/sbin/gluster',
            gluster_peer_list: 'example1,example2',
            gluster_volume_list: 'gl1.example.com:/glusterfs/backup,gl2.example.com:/glusterfs/backup'
          )
        end
        let :params do
          {
            volumes:
            {
              'data1' => {
                'replica' => 2,
                'bricks'  => ['srv1.local:/brick1/brick', 'srv2.local:/brick1/brick'],
                'options' => ['server.allow-insecure: on']
              }
            }
          }
        end

        it 'creates gluster::volume' do
          is_expected.to contain_gluster__volume('data1').with(
            name: 'data1',
            replica: 2,
            bricks: ['srv1.local:/brick1/brick', 'srv2.local:/brick1/brick'],
            options: ['server.allow-insecure: on']
          )
        end
      end

      context 'when volumes incorrectly defined' do
        let :params do
          {
            volumes: { 'data1' => %w[this is an array] }
          }
        end

        it 'fails' do
          expect do
            is_expected.to contain_gluster__volume('data1')
          end.to raise_error(Puppet::Error, %r{})
        end
      end
    end
  end
end
