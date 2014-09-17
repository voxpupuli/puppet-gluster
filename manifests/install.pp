# == Class gluster::install
#
# install the Gluster packages
#
# === Parameters
#
# server: whether or not to install the server components
# client: whether or not to install the client components
# server_package: the server package name
# client_package: the client package name
# repo: whether or not to use a repo, or the distribution's default packages
# version: the Gluster version to install
#
# === Example
#
# class { gluster::install:
#   server  => true,
#   client  => true,
#   repo    => true,
#   version => 3.5,
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
class gluster::install (
  $server         = $::gluster::params::install_server,
  $client         = $::gluster::params::install_client,
  $repo           = $::gluster::params::repo,
  $version        = $::gluster::params::version,
  $server_package = undef,
  $client_package = undef,
) {

  if $repo {
    # use the upstream package names
    $_client_package = $::gluster::params::client_package
    $_server_package = $::gluster::params::server_package
    # install the correct repo
    if ! defined ( Class[::gluster::repo] ) {
      class { '::gluster::repo':
        version => $version,
      }
    }
  } else {
    # use the vendor-supplied package names
    $_client_package = $::gluster::params::vendor_client_package
    $_server_package = $::gluster::params::vendor_server_package
  }

  $_version = $version ? {
    'LATEST' => 'installed',
    default  => $version,
  }

  if $client and $_client_package {
    package { $_client_package:
      ensure => $_version,
      tag    => 'gluster-packages',
    }
  }

  if $server and $_server_package {
    package { $_server_package:
      ensure => $_version,
      notify => Class[::gluster::service],
      tag    => 'gluster-packages',
    }
  }

}
