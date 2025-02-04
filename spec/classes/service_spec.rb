# frozen_string_literal: true

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
          when 'Archlinux', 'Debian', 'Redhat'
            is_expected.to create_service('glusterd')
          end
        end
      end
    end
  end
end
