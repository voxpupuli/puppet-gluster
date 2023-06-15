# frozen_string_literal: true

require 'spec_helper'

describe 'gluster::repo::yum', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      case facts[:osfamily]
      when 'Redhat'
        context 'with all defaults' do
          it { is_expected.to contain_class('gluster::repo::yum') }
          it { is_expected.to compile.with_all_deps }

          it 'installs' do
            is_expected.not_to create_package('yum-plugin-priorities')
            is_expected.to create_yumrepo('glusterfs-x86_64').with(
              enabled: 1,
              baseurl: "http://mirror.centos.org/centos/#{facts[:operatingsystemmajrelease]}/storage/#{facts[:architecture]}/gluster-3.8/",
              gpgcheck: 1,
              gpgkey: "http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-#{facts[:operatingsystemmajrelease]}"
            )
          end
        end

        context 'bogus version' do
          let :params do
            {
              version: 'foobar'
            }
          end

          it 'does not install' do
            is_expected.to compile.and_raise_error(%r{doesn't make sense!})
          end
        end

        context 'unsupported architecture' do
          let :facts do
            super().merge(
              architecture: 'zLinux'
            )
          end

          it 'does not install' do
            is_expected.to compile.and_raise_error(%r{not yet supported})
          end
        end

        context 'latest Gluster with priority' do
          let :params do
            {
              priority: '50'
            }
          end

          it 'installs' do
            is_expected.to create_package('yum-plugin-priorities')
            is_expected.to create_yumrepo('glusterfs-x86_64').with(
              enabled: 1,
              baseurl: "http://mirror.centos.org/centos/#{facts[:operatingsystemmajrelease]}/storage/#{facts[:architecture]}/gluster-3.8/",
              gpgcheck: 1,
              gpgkey: "http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-#{facts[:operatingsystemmajrelease]}",
              priority: '50'
            )
          end
        end
      end
    end
  end
end
