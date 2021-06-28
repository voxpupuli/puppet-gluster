require 'spec_helper'

describe 'gluster::client', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let(:facts) do
        facts
      end

      case facts[:osfamily]
      when 'Redhat'
        context 'with all defaults' do
          it { is_expected.to contain_class('gluster::client') }
          it { is_expected.to compile.with_all_deps }
          it 'includes gluster' do
            is_expected.to create_class('gluster')
          end
        end
        context 'when a version number is specified' do

          it 'includes gluster::install with version 3.6.1' do
            is_expected.to create_class('gluster')
          end
        end
        context 'when repo is false' do

          it 'includes gluster::install with repo=>false' do
            is_expected.to create_class('gluster')
          end
        end
      when 'Debian'
        context 'with all defaults' do
          it { is_expected.to contain_class('gluster::client') }
          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_class('gluster')
            is_expected.to contain_class('gluster::install').with(
              repo: true,
              client_package: 'glusterfs_client',
              version: 'Latest'
            )
          }
        end
        context 'when a version number is specified' do
          let :params do
            {
              version: '3.6.1'
            }
          end

          it 'includes gluster::install with version 3.6.1' do
            is_expected.to create_class('gluster::install').with(
              repo: true,
              client_package: 'glusterfs-client',
              version: '3.6.1'
            )
          end
        end
        context 'when repo is false' do

          it 'includes gluster::install with repo=>false' do
            is_expected.to create_class('gluster::install').with(
              repo: false,
              client_package: 'glusterfs-client',
              version: 'LATEST'
            )
          end
        end
      when 'Archlinux'
        context 'with all defaults' do
          it { is_expected.to contain_class('gluster::client') }
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_package('glusterfs') }
        end
      end
    end
  end
end
