# == Class: Gluster
#
# Installs GlusterFS and optionally creates a trusted storage pool
#
# === Parameters
#
# client: whether to install the Gluster client package(s)
# pool: the name of the trusted storage pool to create
# repo: whether to install and manage the upstream Gluster repo
# server: whether to the install the Gluster server packages
# use_exported_resources: whether or not to export this server's gluster::server and
#                         collect other gluster::server resources
# version: the version to install
# volumes: optional list of volumes (and their properties) to create
#
# === Example
#
# class { ::gluster:
#   client                 => false,
#   server                 => true,
#   pool                   => 'production',
#   use_exported_resources => true,
#   version                => '3.5',
#   volumes                => { 'data1' => {
#                                 replica => 2,
#                                 bricks  => [ 'srv1.local:/export/brick1/brick',
#                                              'srv2.local:/export/brick1/brick',
#                                              'srv3.local:/export/brick1/brick',
#                                              'srv4.local:/export/brick1/brick', ],
#                                 options => [ 'server.allow-insecure: on',
#                                              'nfs.disable: true', ],
#                               },
#                             },
#  }
#
# === Authors
#
# Scott Merrill <smerrill@covermymeds.com>
#
# === Copyright
#
# Copyright 2014 CoverMyMeds, unless otherwise noted
#
class gluster  (
  $client                 = $::gluster::params::install_client,
  $client_package         = $::gluster::params::client_package,
  $pool                   = $::gluster::params::pool,
  $repo                   = $::gluster::params::repo,
  $repo_url               = undef,
  $server                 = $::gluster::params::install_server,
  $server_package         = $::gluster::params::server_package,
  $use_exported_resources = $::gluster::params::export_resources,
  $version                = $::gluster::params::version,
  $volumes                = undef,
) inherits ::gluster::params {

  class { '::gluster::install':
    server         => $server,
    server_package => $server_package,
    client         => $client,
    client_package => $client_package,
    version        => $version,
    repo           => $repo,
  }

  if $server {
    # if we installed the server bits, manage the service
    class { '::gluster::service':
      ensure => $::gluster::params::service_enable,
    }

    if $use_exported_resources {
      # first we export this server's instance
      @@gluster::peer { $::fqdn:
        pool => $pool,
      }

      # then we collect all instances
      Gluster::Peer <<| pool == $pool |>>
    }

    if $volumes {
      validate_hash( $volumes )
      create_resources( ::gluster::volume, $volumes )
    }
  }
}
