require 'spec_helper'

describe 'gluster', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      case facts[:os]['family']
      when 'Debian'
       case facts[:os]['release']['major']
       when '10'
         service_name = 'glusterd'
       when '9'
         service_name =  'glusterfs-server'
       end
       client_package = 'glusterfs-client'
       server_package = 'glusterfs-server'
       repo = true
      when 'RedHat'
       case facts[:os]['release']['major']
       when '7'
        client_package = 'glusterfs-fuse'
       when '8'
         client_package = 'glusterfs'
       end
       service_name = 'glusterd'
       server_package = 'glusterfs-server'
       repo = true
      when 'Suse'
       service_name = 'glusterd'
       client_package = 'glusterfs'
       server_package = 'glusterfs'
       repo = false
      when 'Archlinux'
       service_name = 'glusterd'
       client_package = 'glusterfs'
       server_package = 'glusterfs'
       repo = false
      end

      context 'with all defaults' do
        it { is_expected.to contain_class('gluster') }
        unless facts[:os]['family'] == 'Archlinux' || facts[:os]['family'] == 'Suse'
          it { is_expected.to contain_class('gluster::repo') }
        end
        it { is_expected.to compile.with_all_deps }
        it 'includes classes' do
          is_expected.to contain_class('gluster::install')
          is_expected.to contain_class('gluster::service')
        end
        it 'manages the Gluster service' do
          is_expected.to create_class('gluster::service').with(ensure: true)
        end
      end

        context 'specific stuff' do
          it { is_expected.to contain_service(service_name) }
          unless facts[:os]['family'] == 'Archlinux' || facts[:os]['family'] == 'Suse'
            case facts[:os]['family']
            when 'RedHat'
              it { is_expected.to contain_class('gluster::repo::yum') }
              it { is_expected.to contain_yumrepo('glusterfs-x86_64') }
            when 'Debian'
              it { is_expected.to contain_class('gluster::repo::apt') }
              it { is_expected.to contain_apt__source('glusterfs-LATEST') }
            end
          end
          it 'creates gluster::install' do
            is_expected.to create_class('gluster::install').with(
              install_server: true,
              server_package: server_package,
              install_client: true,
              client_package: client_package,
              version: 'LATEST',
              repo: repo
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
              install_server: true,
              server_package: 'custom-gluster-server',
              install_client: true,
              client_package: 'custom-gluster-client',
              version: '3.1.4',
              repo: false
            )
          end
          it 'installs custom-gluster-client and custom-gluster-server' do
            is_expected.to create_package('custom-gluster-client')
            is_expected.to create_package('custom-gluster-server')
          end

          it 'creates gluster::install' do
            is_expected.to create_class('gluster::install').with(
              install_server: true,
              server_package: 'custom-gluster-server',
              install_client: true,
              client_package: 'custom-gluster-client',
              version: '3.1.4',
              repo: false
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

      context 'when volumes defined without replica' do
        let(:facts) do
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
                'bricks'  => ['srv1.local:/brick1/brick', 'srv2.local:/brick1/brick']
              }
            }
          }
        end

        it 'creates gluster::volume' do
          is_expected.to contain_gluster__volume('data1').with(
            name: 'data1',
            replica: nil,
            bricks: ['srv1.local:/brick1/brick', 'srv2.local:/brick1/brick']
          )
        end
        it 'executes command without replica' do
          is_expected.not_to contain_exec('gluster create volume data1').with(
            command: %r{.* replica .*}
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
          is_expected.to compile.and_raise_error(%r{Expected value of type Hash, got Array})
        end
      end
    end
  end
