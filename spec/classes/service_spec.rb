require 'spec_helper'
require 'pp'

describe 'gluster::service', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      service_name = case facts[:os]['family']
                     when 'Debian'
                       case facts[:os]['release']['major']
                       when '10'
                         'glusterd'
                       when '9'
                         'glusterfs-server'
                       end
                      when 'Redhat'
                       'glusterd'
                      when 'Suse'
                       'glusterd'
                      when 'Archlinux'
                        'glusterd'
                     end
      pp service_name

      context 'with all defaults' do
        it { is_expected.to compile.with_all_deps }
        it 'starts the service' do
          is_expected.to create_service(service_name)
        end
      end
    end
  end
end
