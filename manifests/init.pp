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
# @param priority
#   The priority for the apt/yum repository. Useful to overwrite other repositories like EPEL
# @param repo_key_source
#   Link/path to the GPG key for the repository. Currently only used at RedHat based platforms
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
class gluster  (
  Boolean $client             = $gluster::params::install_client,
  $client_package             = $gluster::params::client_package,
  $pool                       = $gluster::params::pool,
  $repo                       = $gluster::params::repo,
  String $release             = $gluster::params::release,
  $server                     = $gluster::params::install_server,
  $server_package             = $gluster::params::server_package,
  $use_exported_resources     = $gluster::params::export_resources,
  $version                    = $gluster::params::version,
  Optional $repo_key_source   = $gluster::params::repo_key_source,
  Optional[Hash] $volumes     = undef,
  Optional[Integer] $priority = undef,
) inherits gluster::params {

  # if we manage the repository, we also need a GPG key
  if $repo {
    assert_type(Variant[Stdlib::Absolutepath, Stdlib::HTTPSUrl], $repo_key_source)
  }

  class { 'gluster::install':
    server          => $server,
    server_package  => $server_package,
    client          => $client,
    client_package  => $client_package,
    version         => $version,
    repo            => $repo,
    release         => $release,
    priority        => $priority,
    repo_key_source => $repo_key_source,
  }

  if $server {
    # if we installed the server bits, manage the service
    class { 'gluster::service':
      ensure => $gluster::params::service_enable,
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
      create_resources( ::gluster::volume, $volumes )
    }
  }
}
