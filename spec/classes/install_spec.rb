# frozen_string_literal: true

require 'spec_helper'

describe 'gluster::install', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end
      let :pre_condition do
        'require gluster::service'
      end

      context 'with defaults' do
        it { is_expected.to compile.with_all_deps }

        case facts[:osfamily]
        when 'Redhat'
          # rubocop:disable RSpec/RepeatedExample
          it { is_expected.to create_package('glusterfs-server') }
          it { is_expected.to create_package('glusterfs-fuse') }
          it { is_expected.to create_class('gluster::repo').with(version: 'LATEST') }
        when 'Debian'
          it { is_expected.to create_package('glusterfs-server') }
          it { is_expected.to create_package('glusterfs-client') }

          it { is_expected.to create_class('gluster::repo').with(version: 'LATEST') } unless os == 'ubuntu-22.04-x86_64'
          # rubocop:enable RSpec/RepeatedExample
        end
      end

      context 'when repo is false' do
        let :params do
          { repo: false }
        end

        it { is_expected.not_to create_class('gluster::repo') }
      end

      context 'when client is false' do
        let :params do
          { client: false }
        end

        case facts[:osfamily]
        when 'Redhat'
          it { is_expected.not_to create_package('glusterfs-fuse') }
        when 'Debian'
          it { is_expected.not_to create_package('glusterfs-client') }
        end
      end

      context 'when server is false' do
        let :params do
          { server: false }
        end

        case facts[:osfamily]
        when 'Redhat', 'Debian'
          it { is_expected.not_to create_package('glusterfs-server') }
        end
      end

      context 'installing on an unsupported architecture' do
        let :facts do
          # deep_merge modifies facts in place
          facts = super().dup
          facts[:os] = facts[:os].merge(architecture: 'zLinux')
          facts
        end

        case facts[:osfamily]
        when 'Archlinux', 'Suse'
          it { is_expected.not_to create_class('gluster::repo') }
        else
          it { is_expected.to compile.and_raise_error(%r{not yet supported}) } unless os == 'ubuntu-22.04-x86_64'
        end
      end
    end
  end
end
