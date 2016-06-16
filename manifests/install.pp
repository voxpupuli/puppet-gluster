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
  $server          = $gluster::params::install_server,
  $client          = $gluster::params::install_client,
  $repo            = $gluster::params::repo,
  $version         = $gluster::params::version,
  $package_version = $gluster::params::package_version,
  $server_package  = $gluster::params::server_package,
  $client_package  = $gluster::params::client_package,
) inherits ::gluster::params {

  if $repo {
    # install the correct repo
    if ! defined ( Class[::gluster::repo] ) {
      class { '::gluster::repo':
        version => $version,
      }
    }
  }

  # if the user didn't specify a version, just use "installed".
  # if they did specify a version, assume they provided a valid one
  $_version = $version ? {
    'LATEST' => 'installed',
    default  => $version,
  }
  if $client {
    # we use ensure_packages here because on some distributions the client and server package have different names
    ensure_packages($client_package, {
      ensure => $package_version,
      tag    => 'gluster-packages',
    })
  }
  if $server {
    # we use ensure_packages here because on some distributions the client and server package have different names
    ensure_packages($server_package, {
      ensure => $package_version,
      notify => Class[::gluster::service],
      tag    => 'gluster-packages',
    })
  }
}
