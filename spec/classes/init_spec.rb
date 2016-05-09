require 'spec_helper'

describe 'gluster', type: :class do
  describe 'installing on Red Hat Enterprise Linux' do
    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystem: 'RedHat',
        operatingsystemmajrelease: '6',
        architecture: 'x86_64',
      }
    end
    context 'using all defaults' do
      it 'should create gluster::install' do
        should create_class('gluster::install').with(
          server: true,
          server_package: 'glusterfs-server',
          client: true,
          client_package: 'glusterfs-fuse',
          version: 'LATEST',
          repo: true,
        )
      end
      it 'should manage the Gluster service' do
        should create_class('gluster::service').with(
          ensure: true,
        )
      end
    end
    context 'specific version and package names defined' do
      let :params do {
        server_package: 'custom-gluster-server',
        client_package: 'custom-gluster-client',
        version: '3.1.4',
        repo: false,
      }
      end
      it 'should create gluster::install' do
        should create_class('gluster::install').with(
          server: true,
          server_package: 'custom-gluster-server',
          client: true,
          client_package: 'custom-gluster-client',
          version: '3.1.4',
          repo: false,
        )
      end
      it 'should manage the Gluster service' do
        should create_class('gluster::service').with(
          ensure: true,
        )
      end
    end

    context 'when volumes defined' do
      let :params do
        { volumes:           {
            'data1' => {
              'replica' => 2,
              'bricks'  => ['srv1.local:/brick1/brick', 'srv2.local:/brick1/brick'],
              'options' => ['server.allow-insecure: on'],
            }
          }
        }
      end
      it 'should create gluster::volume' do
        should contain_gluster__volume('data1').with(
          name: 'data1',
          replica: 2,
          bricks: ['srv1.local:/brick1/brick', 'srv2.local:/brick1/brick'],
          options: ['server.allow-insecure: on'],
        )
      end
    end

    context 'when volumes incorrectly defined' do
      let :params do
        { volumes:           {
            'data1' => %w(this is an array)
          }
        }
      end
      it 'should fail' do
        expect {
          should contain_gluster__volume('data1')
        }.to raise_error(Puppet::Error, //)
      end
    end
  end
end
