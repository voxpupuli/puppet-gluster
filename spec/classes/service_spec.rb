require 'spec_helper'

describe 'gluster::service', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      context 'with all defaults' do
        it { should compile.with_all_deps }
        it 'starts the service' do
          case facts[:osfamily]
          when 'Redhat'
            should create_service('glusterd')
          when 'Debian'
            should create_service('glusterfs-server')
          end
        end
      end
    end
  end
end
