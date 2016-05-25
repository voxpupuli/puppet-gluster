require 'spec_helper'

describe 'gluster::volume', type: :define do
  let(:title) { 'myvolume' }
  let(:params) {{ bricks: ['g1:/brick1', 'g2:/brick2'] }}
  let(:facts) {{
    gluster_binary: '/usr/sbin/gluster',
    gluster_peer_list: '',
    gluster_volume_list: '',
  }}

  context 'when volume not yet exists' do
    it { should compile.with_all_deps }
    it { should contain_exec('gluster create volume myvolume') }
  end

  context 'when volume already exists' do
    let(:facts) do
      super().merge(
        gluster_volume_list: 'myvolume',
        gluster_volume_myvolume_bricks: 'g1:/brick1,g2:/brick2',
      )
    end

    it { should compile.with_all_deps }
    it { should_not contain_exec('gluster create volume myvolume') }
  end
end
