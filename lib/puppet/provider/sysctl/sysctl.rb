Puppet::Type.type(:sysctl).provide(:sysctl) do

  confine :kernel => 'linux'
  commands :sysctl => 'sysctl'

  def exists?
    sysctl('-n','-e', resource[:name])
  end

  def self.instances
    self.get_kernelparams
  end

  def self.get_kernelparams
    instances = []
    sysctloutput = sysctl('-a')
    sysctloutput.each do |line|
      if line =~ /=/
        next if line =~ /dev\.cdrom.info/
        kernelsetting = line.split('=')
        instances << new(:name => kernelsetting[0].strip, :value => kernelsetting[1].strip)
      end
    end
    instances
  end

  def value
    thevalue = sysctl('-n','-e', resource[:name])
    thevalue.strip
  end

  def value=(thesetting)
    sysctl('-w', "#{resource[:name]}=#{thesetting}")
  end

end
