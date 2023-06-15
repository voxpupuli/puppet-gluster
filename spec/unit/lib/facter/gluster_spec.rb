# frozen_string_literal: true

# vim: syntax=ruby tabstop=2 softtabstop=2 shiftwidth=2 fdm=marker

require 'spec_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
describe Facter::Util::Fact do
  before do
    Facter.clear
  end

  # {{{ Instance variables

  let(:gluster_binary)          { '/usr/sbin/gluster' }
  let(:gluster_volume_one)      { 'volume1' }
  let(:gluster_brick_path)      { "/data/glusterfs/#{gluster_volume_one}/brick1/brick" }

  let(:gluster_peer_one)        { 'peer1' } # localhost
  let(:gluster_peer_one_uuid)   { '7d1148a2-f19e-4f18-818f-3396ddf38c30' }
  let(:gluster_peer_one_port)   { 49_153 }

  let(:gluster_peer_two)        { 'peer2' }
  let(:gluster_peer_two_uuid)   { 'b8a91151-9d32-43a1-8067-136ec855cb1f' }
  let(:gluster_peer_two_port)   { 49_153 }
  let(:gluster_peer_three)      { 'peer3' }
  let(:gluster_peer_three_uuid) { '35f53c52-83dc-4100-a1f7-4a7cdeee074d' }
  let(:gluster_peer_three_port) { 49_152 }

  let(:gluster_peer_shd_port)   { 'N/A' }

  # {{{ Gluster peers

  let(:gluster_peer_count) { 2 }
  let(:gluster_peer_list) { "#{gluster_peer_two},#{gluster_peer_three}" }
  let(:gluster_peers) do
    {
      gluster_peer_two => {
        'uuid' => gluster_peer_two_uuid,
        'connected' => 1,
        'state' => 3,
        'status' => 'Peer in Cluster'
      },
      gluster_peer_three => {
        'uuid' => gluster_peer_three_uuid,
        'connected' => 1,
        'state' => 3,
        'status' => 'Peer in Cluster'
      }
    }
  end

  # }}}
  # {{{ Gluster volumes

  let(:gluster_volume_list) { gluster_volume_one.to_s }

  let(:gluster_volumes) do
    {
      gluster_volume_one => {
        'status' => 'Started',
        'bricks' => [
          "#{gluster_peer_one}:#{gluster_brick_path}",
          "#{gluster_peer_two}:#{gluster_brick_path}",
          "#{gluster_peer_three}:#{gluster_brick_path}"
        ],
        'features' => {
          'features.cache-invalidation' => 'true'
        },
        'options' => {
          'nfs.disable' => 'on',
          'performance.readdir-ahead' => 'on',
          'auth.allow' => '10.10.0.21,10.10.0.22,10.10.0.23'
        },
        'ports' => [
          gluster_peer_one_port,
          gluster_peer_two_port,
          gluster_peer_three_port,
          gluster_peer_shd_port.to_i, # Self-heal Daemon
          gluster_peer_shd_port.to_i, # Self-heal Daemon
          gluster_peer_shd_port.to_i # Self-heal Daemon
        ]
      }
    }
  end

  # }}}
  # {{{ Volume options

  let(:gluster_volume_options) do
    {
      gluster_volume_one => [
        "features.cache-invalidation: #{gluster_volumes[gluster_volume_one]['features']['features.cache-invalidation']}",
        "nfs.disable: #{gluster_volumes[gluster_volume_one]['options']['nfs.disable']}",
        "performance.readdir-ahead: #{gluster_volumes[gluster_volume_one]['options']['performance.readdir-ahead']}",
        "auth.allow: #{gluster_volumes[gluster_volume_one]['options']['auth.allow']}"
      ]
    }
  end

  # }}}
  # {{{ Volume ports

  let(:gluster_volume_ports) do
    {
      gluster_volume_one => {
        'ports' => [
          gluster_peer_one_port,
          gluster_peer_two_port,
          gluster_peer_three_port,
          gluster_peer_shd_port, # Self-heal Daemon
          gluster_peer_shd_port, # Self-heal Daemon
          gluster_peer_shd_port # Self-heal Daemon
        ]
      }
    }
  end

  # }}}

  # {{{ Xml

  # {{{ No peer

  let(:gluster_no_peer) do
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <cliOutput>
      <opRet>0</opRet>
      <opErrno>0</opErrno>
      <opErrstr/>
      <peerStatus/>
    </cliOutput>'
  end

  # }}}
  # {{{ No volume

  let(:gluster_no_volume) do
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <cliOutput>
      <opRet>0</opRet>
      <opErrno>0</opErrno>
      <opErrstr/>
      <volInfo>
        <volumes>
          <count>0</count>
        </volumes>
      </volInfo>
    </cliOutput>'
  end

  # }}}
  # {{{ Peer status

  let(:gluster_peer_status_xml) do
    "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
    <cliOutput>
      <opRet>0</opRet>
      <opErrno>0</opErrno>
      <opErrstr/>
      <peerStatus>
        <peer>
          <uuid>#{gluster_peers[gluster_peer_two]['uuid']}</uuid>
          <hostname>#{gluster_peer_two}</hostname>
          <hostnames>
            <hostname>#{gluster_peer_two}</hostname>
          </hostnames>
          <connected>#{gluster_peers[gluster_peer_two]['connected']}</connected>
          <state>#{gluster_peers[gluster_peer_two]['state']}</state>
          <stateStr>#{gluster_peers[gluster_peer_two]['status']}</stateStr>
        </peer>
        <peer>
          <uuid>#{gluster_peers[gluster_peer_three]['uuid']}</uuid>
          <hostname>#{gluster_peer_three}</hostname>
          <hostnames>
            <hostname>#{gluster_peer_three}</hostname>
          </hostnames>
          <connected>#{gluster_peers[gluster_peer_three]['connected']}</connected>
          <state>#{gluster_peers[gluster_peer_three]['state']}</state>
          <stateStr>#{gluster_peers[gluster_peer_three]['status']}</stateStr>
        </peer>
      </peerStatus>
    </cliOutput>"
  end

  # }}}
  # {{{ Volume info

  let(:gluster_volume_info_xml) do
    "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
    <cliOutput>
      <opRet>0</opRet>
      <opErrno>0</opErrno>
      <opErrstr/>
      <volInfo>
        <volumes>
          <volume>
            <name>#{gluster_volume_one}</name>
            <id>208c58eb-44da-467c-b73d-3e52a1d9d544</id>
            <status>1</status>
            <statusStr>#{gluster_volumes[gluster_volume_one]['status']}</statusStr>
            <snapshotCount>0</snapshotCount>
            <brickCount>3</brickCount>
            <distCount>3</distCount>
            <stripeCount>1</stripeCount>
            <replicaCount>1</replicaCount>
            <arbiterCount>0</arbiterCount>
            <disperseCount>3</disperseCount>
            <redundancyCount>1</redundancyCount>
            <type>4</type>
            <typeStr>Disperse</typeStr>
            <transport>0</transport>
            <xlators/>
            <bricks>
              <brick uuid=\"#{gluster_peer_one_uuid}\">#{gluster_peer_one}:#{gluster_brick_path}<name>#{gluster_peer_one}:#{gluster_brick_path}</name><hostUuid>#{gluster_peer_one_uuid}</hostUuid><isArbiter>0</isArbiter></brick>
              <brick uuid=\"#{gluster_peer_two_uuid}\">#{gluster_peer_two}:#{gluster_brick_path}<name>#{gluster_peer_two}:#{gluster_brick_path}</name><hostUuid>#{gluster_peer_two_uuid}</hostUuid><isArbiter>0</isArbiter></brick>
              <brick uuid=\"#{gluster_peer_three_uuid}\">#{gluster_peer_three}:#{gluster_brick_path}<name>#{gluster_peer_three}:#{gluster_brick_path}</name><hostUuid>#{gluster_peer_three_uuid}</hostUuid><isArbiter>0</isArbiter></brick>
            </bricks>
            <optCount>4</optCount>
            <options>
              <option>
                <name>features.cache-invalidation</name>
                <value>#{gluster_volumes[gluster_volume_one]['features']['features.cache-invalidation']}</value>
              </option>
              <option>
                <name>nfs.disable</name>
                <value>#{gluster_volumes[gluster_volume_one]['options']['nfs.disable']}</value>
              </option>
              <option>
                <name>performance.readdir-ahead</name>
                <value>#{gluster_volumes[gluster_volume_one]['options']['performance.readdir-ahead']}</value>
              </option>
              <option>
                <name>auth.allow</name>
                <value>#{gluster_volumes[gluster_volume_one]['options']['auth.allow']}</value>
              </option>
            </options>
          </volume>
          <count>1</count>
        </volumes>
      </volInfo>
    </cliOutput>"
  end

  # }}}
  # {{{ Volume status

  let(:gluster_volume_one_status_xml) do
    "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
    <cliOutput>
      <opRet>0</opRet>
      <opErrno>0</opErrno>
      <opErrstr/>
      <volStatus>
        <volumes>
          <volume>
            <volName>#{gluster_volume_one}</volName>
            <nodeCount>6</nodeCount>
            <node>
              <hostname>#{gluster_peer_one}</hostname>
              <path>#{gluster_brick_path}</path>
              <peerid>#{gluster_peer_one_uuid}</peerid>
              <status>1</status>
              <port>#{gluster_peer_one_port}</port>
              <ports>
                <tcp>#{gluster_peer_one_port}</tcp>
                <rdma>N/A</rdma>
              </ports>
              <pid>1773</pid>
            </node>
            <node>
              <hostname>#{gluster_peer_two}</hostname>
              <path>#{gluster_brick_path}</path>
              <peerid>#{gluster_peer_two_uuid}</peerid>
              <status>1</status>
              <port>#{gluster_peer_two_port}</port>
              <ports>
                <tcp>#{gluster_peer_two_port}</tcp>
                <rdma>N/A</rdma>
              </ports>
              <pid>1732</pid>
            </node>
            <node>
              <hostname>#{gluster_peer_three}</hostname>
              <path>#{gluster_brick_path}</path>
              <peerid>#{gluster_peer_three_uuid}</peerid>
              <status>1</status>
              <port>#{gluster_peer_three_port}</port>
              <ports>
                <tcp>#{gluster_peer_three_port}</tcp>
                <rdma>N/A</rdma>
              </ports>
              <pid>2175</pid>
            </node>
            <node>
              <hostname>Self-heal Daemon</hostname>
              <path>localhost</path>
              <peerid>#{gluster_peer_one_uuid}</peerid>
              <status>1</status>
              <port>#{gluster_peer_shd_port}</port>
              <ports>
                <tcp>#{gluster_peer_shd_port}</tcp>
                <rdma>N/A</rdma>
              </ports>
              <pid>12189</pid>
            </node>
            <node>
              <hostname>Self-heal Daemon</hostname>
              <path>#{gluster_peer_three}</path>
              <peerid>#{gluster_peer_three_uuid}</peerid>
              <status>1</status>
              <port>#{gluster_peer_shd_port}</port>
              <ports>
                <tcp>#{gluster_peer_shd_port}</tcp>
                <rdma>N/A</rdma>
              </ports>
              <pid>22521</pid>
            </node>
            <node>
              <hostname>Self-heal Daemon</hostname>
              <path>#{gluster_peer_two}</path>
              <peerid>#{gluster_peer_two_uuid}</peerid>
              <status>1</status>
              <port>#{gluster_peer_shd_port}</port>
              <ports>
                <tcp>#{gluster_peer_shd_port}</tcp>
                <rdma>N/A</rdma>
              </ports>
              <pid>31403</pid>
            </node>
            <tasks/>
          </volume>
        </volumes>
      </volStatus>
    </cliOutput>"
  end

  # }}}

  # }}}

  # }}}

  # {{{ Gluster not running

  context 'gluster not running' do
    before do
      allow(Facter).to receive(:value) # Stub all other calls
      allow(Facter).to receive(:value).with('gluster_custom_binary').and_return(gluster_binary)
      allow(File).to receive(:executable?).with(gluster_binary).and_return(true)
      allow(Facter::Util::Resolution).to receive(:exec).with("#{gluster_binary} peer status --xml").and_return('Connection failed. Please check if gluster daemon is operational.')
      allow(Facter::Util::Resolution).to receive(:exec).with("#{gluster_binary} volume info --xml").and_return('Connection failed. Please check if gluster daemon is operational.')
    end

    it 'detect gluster binary' do
      expect(Facter.fact(:gluster_binary).value).to eq(gluster_binary)
    end

    it 'null peer count' do
      expect(Facter.fact(:gluster_peer_count).value).to eq(0)
    end

    it 'empty peer list' do
      expect(Facter.fact(:gluster_peer_list).value).to eq('')
    end

    it 'empty peers hash' do
      expect(Facter.fact(:gluster_peers).value).to eq({})
    end

    it 'empty volumes hash' do
      expect(Facter.fact(:gluster_volumes).value).to eq({})
    end

    it 'nil gluster_volume_list' do
      expect(Facter.fact(:gluster_volume_list)).to eq(nil)
    end

    it 'nil gluster_volume_volume_bricks' do
      expect(Facter.fact(:"gluster_volume_#{gluster_volume_one}_bricks")).to eq(nil)
    end

    it 'nil gluster_volume_volume_options' do
      expect(Facter.fact(:"gluster_volume_#{gluster_volume_one}_options")).to eq(nil)
    end

    it 'nil gluster_volume_volume_ports' do
      expect(Facter.fact(:"gluster_volume_#{gluster_volume_one}_ports")).to eq(nil)
    end
  end

  # }}}
  # {{{ No peers and no volumes

  context 'no peers and no volumes' do
    before do
      allow(Facter).to receive(:value) # Stub all other calls
      allow(Facter).to receive(:value).with('gluster_custom_binary').and_return(gluster_binary)
      allow(File).to receive(:executable?).with(gluster_binary).and_return(true)
      allow(Facter::Util::Resolution).to receive(:exec).with("#{gluster_binary} peer status --xml") { gluster_no_peer }
      allow(Facter::Util::Resolution).to receive(:exec).with("#{gluster_binary} volume info --xml") { gluster_no_volume }
    end

    it 'detect gluster binary' do
      expect(Facter.fact(:gluster_binary).value).to eq(gluster_binary)
    end

    it 'null peer count' do
      expect(Facter.fact(:gluster_peer_count).value).to eq(0)
    end

    it 'empty peer list' do
      expect(Facter.fact(:gluster_peer_list).value).to eq('')
    end

    it 'empty peers hash' do
      expect(Facter.fact(:gluster_peers).value).to eq({})
    end

    it 'empty volumes hash' do
      expect(Facter.fact(:gluster_volumes).value).to eq({})
    end

    it 'nil gluster_volume_list' do
      expect(Facter.fact(:gluster_volume_list)).to eq(nil)
    end

    it 'nil gluster_volume_volume_bricks' do
      expect(Facter.fact(:"gluster_volume_#{gluster_volume_one}_bricks")).to eq(nil)
    end

    it 'nil gluster_volume_volume_options' do
      expect(Facter.fact(:"gluster_volume_#{gluster_volume_one}_options")).to eq(nil)
    end

    it 'nil gluster_volume_volume_ports' do
      expect(Facter.fact(:"gluster_volume_#{gluster_volume_one}_ports")).to eq(nil)
    end
  end

  # }}}
  # {{{ Two peers and no volumes

  context 'two peers and no volumes' do
    before do
      allow(Facter).to receive(:value) # Stub all other calls
      allow(Facter).to receive(:value).with('gluster_custom_binary').and_return(gluster_binary)
      allow(File).to receive(:executable?).with(gluster_binary).and_return(true)
      allow(Facter::Util::Resolution).to receive(:exec).with("#{gluster_binary} peer status --xml") { gluster_peer_status_xml }
      allow(Facter::Util::Resolution).to receive(:exec).with("#{gluster_binary} volume info --xml") { gluster_no_volume }
    end

    it 'detect gluster binary' do
      expect(Facter.fact(:gluster_binary).value).to eq(gluster_binary)
    end

    it 'check gluster_peer_count integer' do
      expect(Facter.fact(:gluster_peer_count).value).to eq(gluster_peer_count)
    end

    it 'check gluster_peer_list string' do
      expect(Facter.fact(:gluster_peer_list).value).to eq(gluster_peer_list)
    end

    it 'check gluster_peers hash' do
      expect(Facter.fact(:gluster_peers).value).to eq(gluster_peers)
    end

    it 'empty volumes hash' do
      expect(Facter.fact(:gluster_volumes).value).to eq({})
    end

    it 'nil gluster_volume_list' do
      expect(Facter.fact(:gluster_volume_list)).to eq(nil)
    end

    it 'nil gluster_volume_volume_bricks' do
      expect(Facter.fact(:"gluster_volume_#{gluster_volume_one}_bricks")).to eq(nil)
    end

    it 'nil gluster_volume_volume_options' do
      expect(Facter.fact(:"gluster_volume_#{gluster_volume_one}_options")).to eq(nil)
    end

    it 'nil gluster_volume_volume_ports' do
      expect(Facter.fact(:"gluster_volume_#{gluster_volume_one}_ports")).to eq(nil)
    end
  end

  # }}}
  # {{{ Two peers and one volume

  context 'two peers and one volumes' do
    before do
      allow(Facter).to receive(:value) # Stub all other calls
      allow(Facter).to receive(:value).with('gluster_custom_binary').and_return(gluster_binary)
      allow(File).to receive(:executable?).with(gluster_binary).and_return(true)
      allow(Facter::Util::Resolution).to receive(:exec).with("#{gluster_binary} peer status --xml") { gluster_peer_status_xml }
      allow(Facter::Util::Resolution).to receive(:exec).with("#{gluster_binary} volume info --xml") { gluster_volume_info_xml }
      allow(Facter::Util::Resolution).to receive(:exec).with("#{gluster_binary} volume status #{gluster_volume_one} --xml") { gluster_volume_one_status_xml }
    end

    it 'detect gluster binary' do
      expect(Facter.fact(:gluster_binary).value).to eq(gluster_binary)
    end

    it 'check gluster_peer_count integer' do
      expect(Facter.fact(:gluster_peer_count).value).to eq(gluster_peer_count)
    end

    it 'check gluster_peer_list string' do
      expect(Facter.fact(:gluster_peer_list).value).to eq(gluster_peer_list)
    end

    it 'check gluster_peers hash' do
      expect(Facter.fact(:gluster_peers).value).to eq(gluster_peers)
    end

    it 'check gluster_volumes hash' do
      expect(Facter.fact(:gluster_volumes).value).to eq(gluster_volumes)
    end

    it 'check gluster_volume_list string' do
      expect(Facter.fact(:gluster_volume_list).value).to eq(gluster_volume_list)
    end

    it 'check gluster_volume_volume_bricks (comma separated string)' do
      expect(Facter.fact(:"gluster_volume_#{gluster_volume_one}_bricks").value).to eq(gluster_volumes[gluster_volume_one]['bricks'].join(','))
    end

    it 'check gluster_volume_volume_options (comma separated string)' do
      expect(Facter.fact(:"gluster_volume_#{gluster_volume_one}_options").value).to eq(gluster_volume_options[gluster_volume_one].join(','))
    end

    it 'check gluster_volume_volume_ports (comma separated string)' do
      expect(Facter.fact(:"gluster_volume_#{gluster_volume_one}_ports").value).to eq(gluster_volume_ports[gluster_volume_one]['ports'].join(','))
    end
  end

  # }}}
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
