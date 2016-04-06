# Class: sysctl
#
# This class is a stub for a module that provides a sysctl type.
#   It will create sysctl values if you if passed via 'set'
#
# Parameters:
#   set = {'key' => { value => 'txt', permanent => 'yes', ensure => 'present',}
#
# Requires:
#
# Sample Usage:
#
class sysctl ($set = {}) {
  validate_hash($set)

  if $set {
    create_resources('sysctl', $set)
  }
}
