Puppet::Type.newtype(:sysctl) do
  ensurable
  newparam(:name, :namevar => true) do
    desc "the name of the kernel parameter to fiddle with"
  end

  newproperty(:value) do
    desc "the value that the parameter should be set to"
  end

end




