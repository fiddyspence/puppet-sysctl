require 'spec_helper'

provider_class = Puppet::Type.type(:sysctl).provider(:linux)

describe provider_class do
  subject { provider_class }
  let(:test_dir) { File.join('/tmp', Time.now.to_i.to_s) }
  let(:test_file) { File.join('/tmp', Time.now.to_i.to_s,'sysctl.conf') }
  let(:resource) { Puppet::Type::Sysctl.new({:name => 'vm.swappiness', :path => test_file}) }
  let(:kernel) { 'linux' }
#  subject { Puppet::Type.type(:sysctl).provider(:linux).new(resource) }

  let(:sysctloutput) do
    <<-OUTPUT
net.ipv6.route.gc_elasticity = 0
net.ipv6.route.mtu_expires = 600
net.ipv6.route.min_adv_mss = 1
vm.swappiness = 0
OUTPUT
    end

  let(:parsed_params) { %w( net.ipv6.route.gc_elasticity net.ipv6.route.mtu_expires net.ipv6.route.min_adv_mss vm.swappiness ) }

  before :each do
    @resource = Puppet::Type::Sysctl.new(
      { :name => 'vm.swappiness', :value => 0 }
    )
    @provider = provider_class.new(@resource)
    Puppet::Util.stubs(:which).with('sysctl').returns('/sbin/sysctl')
    subject.stubs(:which).with('sysctl').returns('/sbin/sysctl')
    Facter.stubs(:value).with(:kernel).returns('linux')
    subject.stubs(:sysctl).with(['-a']).returns(sysctloutput)
  end

  after :each do
  end
  describe 'self.instances' do
    it 'returns an array of sysctl' do
      subject.stubs(:sysctl).with('-a').returns(sysctloutput)
      params = subject.instances.collect {|x| x.name }
#      parsed_params.should match_array(params)
    end
  end

end
