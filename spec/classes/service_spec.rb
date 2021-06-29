require 'spec_helper'

describe 'gluster::service', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      service_name = case facts[:os]['family']
                     when 'Debian'
                       case facts[:os]['release']['major']
                       when '9'
                         'glusterfs-server'
                       end
                     else
                       'glusterd'
                     end

      context 'with all defaults' do
        it { is_expected.to compile.with_all_deps }
        it 'starts the service' do
          is_expected.to create_service(service_name)
        end
      end
    end
  end
end
