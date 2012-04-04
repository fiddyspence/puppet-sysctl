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
      next if line =~ /dev.cdrom.info/
      if line =~ /=/
        kernelsetting = line.split('=')
        instances << new(:name => kernelsetting[0].strip, :value => kernelsetting[1].strip)
      end
    end
    instances
  end

  def permanent
    lines.find do |line|
      if line =~ /^#{resource[:name]}/
        return true
      end
    end
    false
  end

  def destroy
    local_lines = lines
    File.open(resource[:path],'w') do |fh|
      fh.write(local_lines.reject{|l| l =~ /^#{resource[:name]}\s?\=\s?[\S+]$/ }.join(''))
    end
  end

  def permanent=(ispermanent)
    if ispermanent
        a = permanent
        b = ( resource[:value] == nil ? value : resource[:value] ) 
        if a == false
          File.open(resource[:path], 'a') do |fh|
            fh.puts "#{resource[:name]} = #{b}"
          end
        end
    end
  end

  def value
    thevalue = sysctl('-n','-e', resource[:name])
    thevalue.strip
  end

  def value=(thesetting)
    sysctl('-w', "#{resource[:name]}=#{thesetting}")
    if resource[:permanent]
      #do some permanence shit here
    end
  end

  private
  def lines
    @lines ||= File.readlines(resource[:path])
  end

#  def create
#    File.open(resource[:path], 'a') do |fh|
#      fh.puts resource[:line]
#    end
#  end
#
end
