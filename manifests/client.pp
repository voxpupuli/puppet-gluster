# == Class: gluster::client
#
# Ensure that the Gluster FUSE client package is installed
# Note: this is a convenience class to ensure that *just* the client
# is installed.  If you need both client and server, please use
# ::gluster::install or ::gluster::init
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
#   repo => true,
#   client_package => 'glusterfs-fuse',
#   version => 'LATEST',
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
  $repo           = $gluster::params::repo,
  $client_package = $gluster::params::client_package,
  $version        = $gluster::params::version,
) inherits ::gluster::params {

  class { 'gluster::install':
    server         => false,
    client         => true,
    repo           => $repo,
    version        => $version,
    client_package => $client_package,
  }
}
