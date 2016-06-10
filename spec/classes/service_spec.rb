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
          should create_service('glusterd')
        end
      end
    end
  end
end
