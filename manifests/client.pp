# == Class: gluster::client
#
# Ensure that the Gluster FUSE client package is installed
#
# === Parameters
#
# repo: boolean value to determine whether to use the GlusterFS repository
# client_package: the name of the client package to install.
# version: the version of the client tools to install.
#
# === Example
#
# class { gluster::client:
#   repo           => true,
#   client_package => 'glusterfs-fuse',
#   version        => 'LATEST',
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
class gluster::client (
  $repo           = $::gluster::params::repo,
  $client_package = $::gluster::params::client_package,
  $version        = $::gluster::params::version,
) inherits gluster::params {
  if $repo {
    require ::gluster::repo
  }

  $_version = $version ? {
    'LATEST' => 'installed',
    default  => $version,
  }

  package { $client_package:
    ensure => $_version,
  }
}
