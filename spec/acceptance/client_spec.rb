# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'gluster client' do
  context 'with defaults' do
    it 'idempotently run' do
      pp = <<-EOS

       class { 'gluster':
         client  => true,
         server  => false,
       }

      EOS

      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end

  context 'packages installed' do
    case os[:family]
    when 'debian'

      describe package('glusterfs-client') do
        it { is_expected.to be_installed }
      end

    when 'redhat'

      describe package('glusterfs') do
        it { is_expected.to be_installed }
      end
    end
  end
end
