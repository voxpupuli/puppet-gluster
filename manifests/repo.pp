#
# == Class gluster::repo
#
# enables an upstream GlusterFS repository
#
# Note that this module is a wrapper for sub-classes that implement
# the specific repository type, ie:  gluster::repo::yum
#
# === Parameters
#
# None!
#
# === Examples
#
# class { ::gluster::repo }
#
# === Authors
#
# Scott Merrill <smerrill@covermymeds.com>
#
# === Copyright
#
# Copyright 2014 CoverMyMeds, unless otherwise noted
#
class gluster::repo (
  $version = $::gluster::params::version,
) {
  case $::osfamily {
    'RedHat': {
      class { '::gluster::repo::yum':
        version => $version
      }
    }
    default: { fail("${::osfamily} not yet supported!") }
  }
}
