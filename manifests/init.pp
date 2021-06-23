# @summary Installs GlusterFS and optionally creates a trusted storage pool
#
# @param client
#    whether to install the Gluster client package(s)
# @param pool
#    the name of the trusted storage pool to create
# @param repo
#    whether to install and manage the upstream Gluster repo
# @param server
#    whether to the install the Gluster server packages
# @param use_exported_resources
#    whether or not to export this server's gluster::server and collect other
#    gluster::server resources
# @param version
#    the version to install
# @param volumes
#    optional list of volumes (and their properties) to create
#
# @example
#   class { ::gluster:
#     client                 => false,
#     server                 => true,
#     pool                   => 'production',
#     use_exported_resources => true,
#     version                => '3.5',
#     volumes                => { 'data1' => {
#                                   replica => 2,
#                                   bricks  => [ 'srv1.local:/export/brick1/brick',
#                                                'srv2.local:/export/brick1/brick',
#                                                'srv3.local:/export/brick1/brick',
#                                                'srv4.local:/export/brick1/brick', ],
#                                   options => [ 'server.allow-insecure: on',
#                                                'nfs.disable: true', ],
#                                 },
#                               },
#   }
#
# @author Scott Merrill <smerrill@covermymeds.com>
# @note Copyright 2014 CoverMyMeds, unless otherwise noted
#
class gluster (
  Boolean $client             = lookup('gluster::install_client', Boolean, deep),
  $client_package             = lookup('gluster::client_package', String, deep),
  $pool                       = lookup('gluster::pool', String, deep),
  $repo                       = lookup('gluster::repo', String, deep),
  $release                    = lookup('gluster::release', String, deep),
  $server                     = lookup('gluster::install_server', String, deep),
  $server_package             = lookup('gluster::server_package', String, deep),
  $use_exported_resources     = lookup('gluster::export_resources', String, deep),
  $version                    = lookup('gluster::version', String, deep),
  Hash[String, Any] $volumes  = {},
) {
  class { 'gluster::install':
    server         => $server,
    server_package => $server_package,
    client         => $client,
    client_package => $client_package,
    version        => $version,
    repo           => $repo,
  }

  if $server {
    # if we installed the server bits, manage the service
    class { 'gluster::service':
      ensure => lookup('gluster::service_enable', Boolean, deep),
    }

    if $use_exported_resources {
      # first we export this server's instance
      @@gluster::peer { $facts['networking']['fqdn']:
        pool => $pool,
      }

      # then we collect all instances
      Gluster::Peer <<| pool == $pool |>>
    }

    $volumes.each |$volume, $options| {
      gluster::volume { $volume:
        * => $options,
      }
    }
  }
}
