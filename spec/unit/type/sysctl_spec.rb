require 'puppet'
require 'spec_helper'
describe Puppet::Type.type(:sysctl) do
  subject { Puppet::Type.type(:sysctl).new(:name => 'vm.swappiness') }

  it 'should accept ensure' do
    subject[:ensure] = :present
    subject[:ensure].should == :present
  end

  it 'value should accept values' do
    subject[:value] = '0'
    subject[:value].should == '0'
  end

  it 'should accept yes as a value for permanent' do
    subject[:permanent] = 'yes'
    subject[:permanent].should == 'yes'
  end
  it 'should accept no as a value for permanent' do
    subject[:permanent] = 'no'
    subject[:permanent].should == 'no'
  end

  it 'should not accept moo as a value for permanent' do
    expect { subject[:permanent] = 'moo'}.should raise_error(Puppet::Error, /Invalid value/)
  end

  it 'should accept kernel as a value for source' do
    subject[:source] = 'kernel'
    subject[:source].should == 'kernel'
  end
  it 'should accept conf as a value for source' do
    subject[:source] = 'conf'
    subject[:source].should == 'conf'
  end
  it 'should not accept moo as a value for source' do
    expect { subject[:source] = 'moo'}.should raise_error(Puppet::Error, /Invalid value/)
  end

  it 'should have a default path' do
    subject[:path].should == '/etc/sysctl.conf'
  end
  it 'should accept a fully qualified path as the target' do
    subject[:path] = '/etc/sysctl.conf.moo'
    subject[:path].should == '/etc/sysctl.conf.moo'
  end
  it 'should not accept a fully qualified path as the target' do
    expect { subject[:path] = 'moo'}.should raise_error(Puppet::Error, /fully qualified path/)
  end


end
