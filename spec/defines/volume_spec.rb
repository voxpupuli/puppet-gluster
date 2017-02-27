require 'spec_helper'

describe 'gluster::volume', type: :define do
  let(:title) { 'storage1' }
  let(:params) do
    {
      replica: 2,
      bricks: [
        'srv1.local:/export/brick1/brick',
        'srv2.local:/export/brick1/brick',
        'srv1.local:/export/brick2/brick',
        'srv2.local:/export/brick2/brick'
      ],
      options: [
        'server.allow-insecure: on',
        'nfs.ports-insecure: on'
      ]
    }
  end

  describe 'strict variables tests' do
    describe 'missing gluster_binary fact' do
      it { is_expected.to compile }
    end

    describe 'missing gluster_peer_list fact' do
      let(:facts) do
        {
          gluster_binary: '/usr/sbin/gluster'
        }
      end
      it { is_expected.to compile }
    end

    describe 'missing gluster_volume_list fact' do
      let(:facts) do
        {
          gluster_binary: '/usr/sbin/gluster',
          gluster_peer_list: 'peer1.example.com,peer2.example.com'
        }
      end
      it { is_expected.to compile }
    end

    describe 'with replica count' do
      let(:title) { 'storage1' }
      let(:facts) {
          {
              gluster_binary: '/usr/bin/gluster',
              gluster_peer_list: 'srv1.local,srv2.local',
              gluster_volume_list: 'storage2',
          }
      }

      it do
          is_expected.to compile
          is_expected.to contain_exec('gluster create volume storage1') \
              .with_command(/replica [\d]+/)
      end
    end

    describe 'no replica count' do
      let(:title) { 'storage1' }
      let(:params) {
        {
          replica: false,
          bricks: [
            'srv1.local:/export/brick1/brick',
            'srv2.local:/export/brick1/brick',
            'srv1.local:/export/brick2/brick',
            'srv2.local:/export/brick2/brick'
          ],
          options: [
            'server.allow-insecure: on',
            'nfs.ports-insecure: on'
          ]
        }
      }

      let(:facts) {
          {
              gluster_binary: '/usr/bin/gluster',
              gluster_peer_list: 'srv1.local,srv2.local',
              gluster_volume_list: 'storage2',
          }
      }

      it do
          is_expected.to compile
          is_expected.to contain_exec('gluster create volume storage1') \
              .without_command(/replica [\d]+/)
      end
    end

    describe 'with all facts' do
      let(:facts) do
        {
          gluster_binary: '/usr/sbin/gluster',
          gluster_peer_list: 'peer1.example.com,peer2.example.com',
          gluster_volume_list: 'gl1.example.com:/glusterfs/backup,gl2.example.com:/glusterfs/backup'
        }
      end
      it { is_expected.to compile }
    end
  end
end
