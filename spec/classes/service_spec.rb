require 'spec_helper'

describe 'gluster::service', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with all defaults' do
        it { is_expected.to compile.with_all_deps }
        it 'starts the service' do
          case facts[:osfamily]
          when 'Redhat'
            is_expected.to create_service('glusterd')
          when 'Debian'
            case facts[:operatingsystemreleasea]
            when '9'
              is_expected.to create_service('glusterfs-server')
            else
              is_expected.to create_service('glusterd')
            end
          when 'Archlinux'
            is_expected.to create_service('glusterd')
          end
        end
      end
    end
  end
end
