# == Class gluster::install
#
# install the Gluster packages
#
# === Parameters
#
# install_server: whether or not to install the server components
# install_client: whether or not to install the client components
# server_package: the server package name
# client_package: the client package name
# repo: whether or not to use a repo, or the distribution's default packages
# version: the Gluster version to install
#
# === Example
#
# class { gluster::install:
#   install_server => true,
#   install_client => true,
#   repo           => true,
#   version        => 3.5,
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
  $install_server = $::gluster::params::install_server,
  $install_client = $::gluster::params::install_client,
  $server_package = $::gluster::params::server_package,
  $client_package = $::gluster::params::client_package,
  $repo           = $::gluster::params::repo,
  $version        = $::gluster::params::version,
) inherits ::gluster::params {

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

  if $install_client {
    package { $client_package:
      ensure => $_version,
    }
  }

  if $install_server {
    package { $server_package:
      ensure => $_version,
      notify => Class[::gluster::service]
    }
  }

}
