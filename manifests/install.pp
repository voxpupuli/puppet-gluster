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
  $server_package = $::gluster::params::server_package,
  $client_package = $::gluster::params::client_package,
  $repo           = $::gluster::params::repo,
  $version        = $::gluster::params::version,
) {

  if $repo {
    if ! defined ( Class[::gluster::repo] ) {
      class { '::gluster::repo':
        version => $version,
      }
    }
  }

  $_version = $version ? {
    'LATEST' => 'installed',
    default  => $version,
  }

  if $client {
    package { $client_package:
      ensure => $_version,
    }
  }

  if $server {
    package { $server_package:
      ensure => $_version,
      notify => Class[::gluster::service]
    }
  }

}
