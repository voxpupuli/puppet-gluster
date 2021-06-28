require 'spec_helper'

describe 'gluster::client', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let(:facts) do
        facts
      end

      client_name = case facts[:os]['family']
                     when 'RedHat'
                       case facts[:os]['release']['major']
                       when '7'
                         'glusterfs-fuse'
                       when '8'
                         'glusterfs'
                       end
                     when 'Debian'
                       case facts[:os]['release']['major']
                       when '9'
                         'glusterfs-client'
                       end
                     when 'Suse'
                       'glusterfs'
                     when 'Archlinux'
                       'glusterfs'
                     end

        context 'with all defaults' do
          it { is_expected.to contain_class('gluster::client') }
          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_class('gluster')
            is_expected.to contain_class('gluster::install').with(
              client_package: client_name,
              version: 'LATEST'
            )
          }
        end
    end
  end
end

        
