require 'spec_helper'

describe 'gluster::peer', type: :define do
  let(:title) { 'peer1.example.com' }

  describe 'missing gluster_binary fact' do
    it { is_expected.to compile }
    it { is_expected.not_to contain_exec('gluster peer probe peer1.example.com') }
  end

  describe 'missing gluster_peer_list fact' do
    let(:facts) do
      {
        gluster_binary: '/usr/sbin/gluster'
      }
    end

    it { is_expected.to compile }
  end

  context 'when already in pool' do
    describe '1 peer' do
      let(:facts) do
        {
          gluster_binary: '/usr/sbin/gluster',
          gluster_peer_count: 1,
          gluster_peer_list: ['peer1.example.com']
        }
      end

      it { is_expected.to compile }
      it { is_expected.not_to contain_exec('gluster peer probe peer1.example.com') }
    end
    describe '2 peers' do
      let(:facts) do
        {
          gluster_binary: '/usr/sbin/gluster',
          gluster_peer_count: 2,
          gluster_peer_list: %w[peer1.example.com peer2.example.com]
        }
      end

      it { is_expected.to compile }
      it { is_expected.not_to contain_exec('gluster peer probe peer1.example.com') }
    end
  end

  context 'when not in pool' do
    describe '0 peers' do
      let(:facts) do
        {
          gluster_binary: '/usr/sbin/gluster',
          gluster_peer_count: 0,
          gluster_peer_list: []
        }
      end

      it { is_expected.to compile }
      it { is_expected.to contain_exec('gluster peer probe peer1.example.com') }
    end
    describe '1 peer' do
      let(:facts) do
        {
          gluster_binary: '/usr/sbin/gluster',
          gluster_peer_count: 1,
          gluster_peer_list: ['peer2.example.com']
        }
      end

      it { is_expected.to compile }
      it { is_expected.to contain_exec('gluster peer probe peer1.example.com') }
    end
    describe '2 peers' do
      let(:facts) do
        {
          gluster_binary: '/usr/sbin/gluster',
          gluster_peer_count: 2,
          gluster_peer_list: %w[peer2.example.com peer3.example.com]
        }
      end

      it { is_expected.to compile }
      it { is_expected.to contain_exec('gluster peer probe peer1.example.com') }
    end
  end

  describe 'self joining (fqdn matches resource title)' do
    let(:facts) do
      {
        gluster_binary: '/usr/sbin/gluster',
        gluster_peer_count: 0,
        gluster_peer_list: '',
        fqdn: 'peer1.example.com'
      }
    end

    it { is_expected.to compile }
    it 'we don\'t try to join with ourselves' do
      is_expected.not_to contain_exec('gluster peer probe peer1.example.com')
    end
  end
end
