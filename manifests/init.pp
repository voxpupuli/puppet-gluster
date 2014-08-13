# == Class: Gluster
#
# Installs GlusterFS and optionally creates a trusted storage pool
#
# === Parameters
#
# pool: the name of the trusted storage pool to create
# use_exported_resources: whether or not to export this server's gluster::server and
#                         collect other gluster::server resources
# volumes: optional list of volumes (and their properties) to create
#
# === Example
#
# class { ::gluster:
#   pool                   => 'production',
#   use_exported_resources => true,
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
  $pool                   = $::gluster::params::pool,
  $use_exported_resources = $::gluster::params::export_resources,
  $volumes                = undef,
) inherits ::gluster::params {

  class { '::gluster::install':
    server         => $::gluster::params::install_server,
    client         => $::gluster::params::install_client,
    server_package => $::gluster::params::server_package,
    client_package => $::gluster::params::client_package,
    version        => $::gluster::params::version,
    repo           => $::gluster::params::repo,
  }

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
