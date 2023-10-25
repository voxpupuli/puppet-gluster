# frozen_string_literal: true

require 'spec_helper'

describe 'gluster::repo::apt', type: :class do
  on_supported_os.each do |os, os_facts|
    # Ubuntu 22.04 does not require a repo
    context "on #{os}", if: os_facts[:os]['family'] == 'Debian' && os_facts[:os]['release']['major'] != '22.04' do
      let(:facts) { os_facts }
      let(:pre_condition) { 'require gluster::params' }

      context 'with all defaults' do
        it { is_expected.to contain_class('gluster::repo::apt') }
        it { is_expected.to compile.with_all_deps }

        it 'installs' do
          location = {
            'Debian' => "https://download.gluster.org/pub/gluster/glusterfs/7/LATEST/Debian/#{facts[:lsbdistcodename]}/#{facts[:architecture]}/apt/",
            'Ubuntu' => 'http://ppa.launchpad.net/gluster/glusterfs-7/ubuntu',
          }
          is_expected.to contain_apt__source('glusterfs-LATEST').with(
            repos: 'main',
            release: facts[:lsbdistcodename].to_s,
            location: location[facts[:os]['name']]
          )
        end
      end

      context 'unsupported architecture' do
        let(:facts) do
          # deep_merge modifies the facts in place
          facts = super().dup
          facts[:os] = facts[:os].merge(architecture: 'zLinux')
          facts
        end

        it 'does not install' do
          is_expected.to compile.and_raise_error(%r{Architecture zLinux not yet supported})
        end
      end

      context 'latest Gluster with priority' do
        let :params do
          {
            priority: '700'
          }
        end

        it 'installs' do
          location = {
            'Debian' => "https://download.gluster.org/pub/gluster/glusterfs/7/LATEST/Debian/#{facts[:lsbdistcodename]}/#{facts[:architecture]}/apt/",
            'Ubuntu' => 'http://ppa.launchpad.net/gluster/glusterfs-7/ubuntu',
          }
          is_expected.to contain_apt__source('glusterfs-LATEST').with(
            repos: 'main',
            release: facts[:lsbdistcodename].to_s,
            location: location[facts[:os]['name']],
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
          location = {
            'Debian' => "https://download.gluster.org/pub/gluster/glusterfs/4.1/LATEST/Debian/#{facts[:lsbdistcodename]}/amd64/apt/",
            'Ubuntu' => 'http://ppa.launchpad.net/gluster/glusterfs-4.1/ubuntu',
          }
          key = {
            'Debian' => {
              'id' => 'EED3351AFD72E5437C050F0388F6CDEE78FA6D97',
              'source' => 'https://download.gluster.org/pub/gluster/glusterfs/4.1/rsa.pub',
            },
            'Ubuntu' => {
              'id' => 'F7C73FCC930AC9F83B387A5613E01B7B3FE869A9',
              'source' => nil,
            },
          }
          is_expected.to contain_apt__source('glusterfs-LATEST').with(
            repos: 'main',
            release: facts[:lsbdistcodename].to_s,
            key: key[facts[:os]['name']],
            location: location[facts[:os]['name']]
          )
        end
      end

      context 'Specific Gluster release 3.12' do
        let :params do
          {
            release: '3.12'
          }
        end

        it 'installs' do
          location = {
            'Debian' => "https://download.gluster.org/pub/gluster/glusterfs/01.old-releases/3.12/LATEST/Debian/#{facts[:lsbdistcodename]}/amd64/apt/",
            'Ubuntu' => 'http://ppa.launchpad.net/gluster/glusterfs-3.12/ubuntu',
          }
          key = {
            'Debian' => {
              'id' => '8B7C364430B66F0B084C0B0C55339A4C6A7BD8D4',
              'source' => 'https://download.gluster.org/pub/gluster/glusterfs/3.12/rsa.pub',
            },
            'Ubuntu' => {
              'id' => 'F7C73FCC930AC9F83B387A5613E01B7B3FE869A9',
              'source' => nil,
            },
          }
          is_expected.to contain_apt__source('glusterfs-LATEST').with(
            repos: 'main',
            release: facts[:lsbdistcodename].to_s,
            key: key[facts[:os]['name']],
            location: location[facts[:os]['name']]
          )
        end
      end
    end
  end
end
