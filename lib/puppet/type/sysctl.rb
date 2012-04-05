Puppet::Type.newtype(:sysctl) do
  ensurable
  newparam(:name, :namevar => true) do
    desc "the name of the kernel parameter to fiddle with"
  end

  newproperty(:value) do
    desc "the value that the running kernel should be set to"
  end

  newproperty(:permanent) do
    desc "whether the value is in [/etc/sysctl.conf]"
    newvalues (/yes|no/)
  end

  newparam(:source) do
    desc "whether to treat the running kernel or sysctl.conf as authoritative"
    newvalues(/kernel|conf/)
    defaultto "conf"
  end

  newparam(:path) do
    desc "which sysctl.conf we are dealing with"
    defaultto '/etc/sysctl.conf'
  end

end
