require 'spec_helper'

describe 'gluster::mount', :type => :define do
  let(:title) { 'rspec' }
  describe 'no volume specified' do
    it 'should fail' do
      expect do
        should contain_mount('rspec')
      end.to raise_error(Puppet::Error, /Volume parameter is mandatory/)
    end
  end
  describe 'bogus ensure value' do
    let(:params) { { :volume => 'rspec', :ensure => 'foobar' } }
    it 'should fail' do
      expect do
        should contain_mount('rspec')
      end.to raise_error(Puppet::Error, /Unknown option/)
    end
  end
end
