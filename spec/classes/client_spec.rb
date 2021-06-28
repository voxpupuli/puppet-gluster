require 'spec_helper'

describe 'gluster::client', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let(:facts) do
        facts
      end

      client_pkg = case facts[:os]['name']
                       when 'RedHat'
                         case facts[:os]['release']['major']
                         when '8'
                           'glusterfs'
                         else
                           'glusterfs-fuse'
                         end
                       when 'Debian'
                           'glusterfs-client'
                       end


        context 'with all defaults' do
          it { is_expected.to contain_class('gluster::client') }
          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_class('gluster')
            is_expected.to contain_class('gluster::install').with(
              client_package: client_pkg,
              version: 'LATEST'
            )
          }
        end
    end
  end
end

        
