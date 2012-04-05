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
        return "yes"
      end
    end
    "no"
  end

  def destroy
    local_lines = lines
    File.open(resource[:path],'w') do |fh|
      fh.write(local_lines.reject{|l| l =~ /^#{resource[:name]}\s?\=\s?[\S+]/ }.join(''))
      fh.flush
    end
  end

  def permanent=(ispermanent)
    if ispermanent == "yes"
      a = permanent
      b = ( resource[:value] == nil ? value : resource[:value] )
      if a == "no"
        File.open(resource[:path], 'a') do |fh|
          fh.puts "#{resource[:name]} = #{b}"
          fh.flush
        end
      else
        local_lines = lines
        b = ( resource[:value] == nil ? value : resource[:value] )
        local_lines.find do |line|
          if line =~ /^#{resource[:name]}/ && line !~ /^#{resource[:name]}\s?=\s?#{b}/
            content = File.read(resource[:path])
            File.open(resource[:path],'w') do |fh|
              fh.write(content.gsub(/\n#{resource[:name]}\s?=\s?[\S+]/,"\n#{resource[:name]}\ =\ #{b}"))
              fh.flush
            end
          end
        end
      end
    else
      local_lines = lines
      File.open(resource[:path],'w') do |fh|
        fh.write(local_lines.reject{|l| l =~ /^#{resource[:name]}/ }.join(''))
        fh.flush
      end
    end
  end

  def value
    thevalue = sysctl('-n','-e', resource[:name])
    kernelvalue = thevalue.strip
    confvalue = false
    local_lines = lines
    local_lines.find do |line|
      if line =~ /^#{resource[:name]}/
        thisparam=line.split('=')
        confvalue = thisparam[1].strip
      end
    end
    conftime = Time.now.to_f
    if confvalue
      if confvalue == kernelvalue
        return kernelvalue
      else
        return "outofsync"
      end
    else
      return kernelvalue
    end

  end

  def value=(thesetting)
    sysctl('-w', "#{resource[:name]}=#{thesetting}")
    local_lines = lines
    b = ( resource[:value] == nil ? value : resource[:value] )
    local_lines.find do |line|
      if line =~ /^#{resource[:name]}/ && line !~ /^#{resource[:name]}\s?=\s?#{b}/
        content = File.read(resource[:path])
        File.open(resource[:path],'w') do |fh|
          # this regex is not perfect yet
          fh.write(content.gsub(/\n#{resource[:name]}\s?=\s?[\S]+/,"\n#{resource[:name]}\ =\ #{b}"))
          fh.flush
        end
      end
    end
  end

  private
  def lines
    @lines = nil
    @lines ||= File.readlines(resource[:path])
  end

end
