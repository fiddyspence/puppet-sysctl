Puppet::Type.type(:sysctl).provide(:linux) do

  confine  :kernel => 'linux'
  commands :sysctl => 'sysctl'

  def exists?
    @property_hash[:ensure] == :present
  end

  def self.prefetch(host)
    instances.each do |prov|
      if pkg = host[prov.name]
        pkg.provider = prov
      end
    end
  end

  def self.instances
    sysctlconf=lines || []
    instances = []
    sysctloutput = sysctl('-a').split(/\n/)
    sysctloutput.each do |line|
      Puppet.debug("Line: " + line.to_s)
      line.strip!
      #next if line =~ /dev.cdrom.info/
      if line =~ /=/
        permanent = :false
        kernelsetting = line.split(/\s?=\s?/)
        setting_name = kernelsetting[0]
        setting_value = kernelsetting[1]
        confval = sysctlconf.grep(/^#{setting_name}\s?=/)
        if confval.empty?
          value = setting_value
          permanent = :false
        else
          permanent = :true
          unless confval[0].split('=')[1].strip == setting_value
            value = "outofsync(sysctl:#{setting_value},config:#{confval[0].split('=')[1].strip})"
          else
            value = setting_value
          end
        end
        instances << new(:ensure => :present, :name => setting_name, :value => value, :permanent => permanent)
      end
    end
    instances
  end

  def destroy
    local_lines = lines
    File.open(@resource[:path],'w') do |fh|
      fh.write(local_lines.reject{|l| l =~ /^#{@resource[:name]}\s?\=\s?[\S+]/ }.join(''))
    end
    @lines = nil
  end

  def permanent
    Puppet.debug("Permanent? " + @property_hash[:permanent].to_s)
    @property_hash[:permanent]
  end

  def create
    sysctloutput = sysctl('-a').split(/\r?\n/)
    Puppet.debug "#{sysctloutput.grep(/^#{@resource[:name]}\s?=/)}"
    if sysctloutput.grep(/^#{@resource[:name]}\s?=/).empty?
      self.fail "Invalid sysctl parameter"
    end
  end

  def permanent=(ispermanent)
    if ispermanent == :true
      b = ( @resource[:value] == nil ? value : @resource[:value] )
      File.open(@resource[:path], 'a') do |fh|
        fh.puts "#{@resource[:name]} = #{b}"
      end
    else
      local_lines = lines
      File.open(@resource[:path],'w') do |fh|
        fh.write(local_lines.reject{|l| l =~ /^#{@resource[:name]}/ }.join(''))
      end
    end
    @lines = nil
    @property_hash[:permanent] = ispermanent
  end

  def value
    @property_hash[:value]
  end

  def value=(thesetting)
    sysctl('-w', "#{@resource[:name]}=#{thesetting}")
    if not (lines.nil? or lines.empty?)
      changed = false
      lines.each_index { |idx|
        if lines[idx] =~ /^#{@resource[:name]}/ and lines[idx] !~ /^#{@resource[:name]}\s?=\s?#{thesetting}$/
          lines[idx] = "#{@resource[:name]}\ =\ #{thesetting}\n"
          changed = true
        end
      }
      if changed
        File.open(@resource[:path],'w') do |fh|
          fh.write(lines)
        end
      end
    end
    @lines = nil
    @property_hash[:value] = thesetting
  end

  def self.lines
    begin
      @lines ||= File.readlines('/etc/sysctl.conf')
    rescue Errno::ENOENT
      return nil
    end
  end
  def lines
    begin
      @lines ||= File.readlines(@resource[:path])
    rescue Errno::ENOENT
      return nil
    end
  end
end
