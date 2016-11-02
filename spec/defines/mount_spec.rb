require 'spec_helper'

describe 'gluster::mount', type: :define do
  let(:title) { 'rspec' }
  describe 'no volume specified' do
    it 'fails' do
      expect do
        is_expected.to contain_mount('rspec')
      end.to raise_error(Puppet::Error, %r{Volume parameter is mandatory})
    end
  end
  describe 'bogus ensure value' do
    let :params do
      {
        volume: 'rspec',
        ensure: 'foobar'
      }
    end
    it 'fails' do
      expect do
        is_expected.to contain_mount('rspec')
      end.to raise_error(Puppet::Error, %r{Unknown option})
    end
  end
end
