require 'puppetlabs_spec_helper/module_spec_helper'

def param_value(subject, type, title, param)
  subject.resource(type, title).send(:parameters)[param.to_sym]
end
$operatingsystems = ['fedora','rhel','centos','suse','opensuse', 'debian','ubuntu']
