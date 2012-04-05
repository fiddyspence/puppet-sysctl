Puppet::Type.type(:sysctl).provide(:sysctl) do

  confine  :kernel => 'linux'
  commands :sysctl => 'sysctl'

  def exists?
    begin
      sysctl('-n', '-e',resource[:name])
    rescue
#     puts "eek"
    end
  end

  def create
    return nil
  end

  def self.instances
    self.get_kernelparams
  end

  def self.get_kernelparams
    instances = []
    sysctloutput = sysctl('-a')
    sysctloutput.each do |line|
    # what to do about the raft of e.g. dev.cdrom.info spam here....
      if line =~ /=/
        kernelsetting = line.split('=')
        instances << new(:name => kernelsetting[0].strip, :value => kernelsetting[1].strip)
      end
    end
    instances
  end

  def destroy
    local_lines = lines
    File.open(resource[:path],'w') do |fh|
      fh.write(local_lines.reject{|l| l =~ /^#{resource[:name]}/ }.join(''))
    end
  end

  def permanent
    lines.find do |line|
      if line =~ /^#{resource[:name]}/
        return "yes"
      end
    end
    "no"
  end

  def permanent=(ispermanent)
    if ispermanent == "yes"
      currentstate = permanent
      desiredvalue = ( resource[:value] == nil ? value : resource[:value] )
      if currentstate == "no"
        File.open(resource[:path], 'a') do |fh|
          fh.puts "#{resource[:name]} = #{desiredvalue}"
        end
      else
        lines.find do |line|
          if line =~ /^#{resource[:name]}/ && line !~ /^#{resource[:name]}\s?=\s?#{desiredvalue}/
            content = File.read(resource[:path])
            File.open(resource[:path],'w') do |fh|
              fh.write(content.gsub(/\n#{resource[:name]}\s?=\s?[\S+]/,"\n#{resource[:name]}\ =\ #{desiredvalue}"))
            end
          end
        end
      end
    else
      local_lines = lines
      File.open(resource[:path],'w') do |fh|
        fh.write(local_lines.reject{|l| l =~ /^#{resource[:name]}/ }.join(''))
      end
    end
    resetlines
  end

  def value
    thevalue = sysctl('-n','-e', resource[:name])
    kernelvalue = thevalue.strip.gsub(/\s+/," ")
    confvalue = false
    lines.find do |line|
      if line =~ /^#{resource[:name]}/
        thisparam=line.split('=')
        confvalue = thisparam[1].strip
      end
    end
    if confvalue
      if confvalue == kernelvalue
        return kernelvalue
      else
        return "outofsync(kernel:#{kernelvalue},sysctl:#{confvalue})"
      end
    end

    kernelvalue

  end

  def value=(thesetting)
    sysctl('-w', "#{resource[:name]}=#{thesetting}")
    desiredvalue = ( resource[:value] == nil ? value : resource[:value] )
    lines.find do |line|
      if line =~ /^#{resource[:name]}/ && line !~ /^#{resource[:name]}\s?=\s?#{desiredvalue}/
        content = File.read(resource[:path])
        File.open(resource[:path],'w') do |fh|
          fh.write(content.gsub(/\n#{resource[:name]}\s?=.+\n/,"\n#{resource[:name]}\ =\ #{desiredvalue}\n"))
        end
      end
    end
    resetlines
  end

  private
  def lines
    @lines ||= File.readlines(resource[:path])
  end

  def resetlines
    # fiddyspence
    # we reset @lines here because of the way we create @lines - we don't want to read the file 100s of times
    # so we only re-read it after we know it has changed, otherwise we assume it doesn't change while we are
    # running
    @lines = nil
  end

end
