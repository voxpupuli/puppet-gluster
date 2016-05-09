require 'spec_helper'

describe 'gluster::service', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} with all defaults" do
      let(:facts) do
        facts
      end
      it { should compile.with_all_deps }
      it 'should start the service' do
        should create_service('glusterd')
      end
    end
  end
end
