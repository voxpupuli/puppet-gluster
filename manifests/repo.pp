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
# repo_url: the URL of the upstream apt repo (not used by yum repos)
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
  $version  = $::gluster::params::version,
  $repo_url = undef,
) inherits ::gluster::params {
  case $::osfamily {
    'RedHat': {
      class { '::gluster::repo::yum':
        version => $version,
      }
    }
    'Debian': {
      if ! defined( '::apt' ) {
        fail( "\nPuppetlabs Apt module is required to manage apt repos on ${::operatingsystem}.\nInstall module with \"puppet module install puppetlabs-apt\".\n" )
      }
      class { '::gluster::repo::apt':
        version  => $version,
        repo_url => $repo_url,
      }
    }
    default: { fail("${::osfamily} not yet supported!") }
  }
}
