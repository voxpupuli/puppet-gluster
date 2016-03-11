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
# version: the version of the upstream repo to enable
#
# === Examples
#
# class { ::gluster::repo
#   version => '3.5.2',
# }
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
) inherits ::gluster::params {
  $_osfamily = getvar('::osfamily')
  case getvar('::osfamily') {
    'RedHat': {
      class { '::gluster::repo::yum':
        version => $version,
      }
    }
    default: { fail("${_osfamily} not yet supported!") }
  }
}
