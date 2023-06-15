# @summary install the Gluster packages
# @api private
#
# @param server
#    whether or not to install the server components
# @param client
#    whether or not to install the client components
# @param server_package
#    the server package name
# @param client_package
#    the client package name
# @param repo
#    whether or not to use a repo, or the distribution's default packages
# @param version
#    the Gluster version to install
#
# @example
#   class { gluster::install:
#     server  => true,
#     client  => true,
#     repo    => true,
#     version => 3.5,
#   }
#
# @author Scott Merrill <smerrill@covermymeds.com>
# @note Copyright 2014 CoverMyMeds, unless otherwise noted
#
class gluster::install (
  Boolean $server        = $gluster::params::install_server,
  Boolean $client        = $gluster::params::install_client,
  Boolean $repo          = $gluster::params::repo,
  String $version        = $gluster::params::version,
  String $server_package = $gluster::params::server_package,
  String $client_package = $gluster::params::client_package,
) inherits gluster::params {
  if $repo {
    # install the correct repo
    if ! defined ( Class['gluster::repo']) {
      class { 'gluster::repo':
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

  $packages = (
    (
      if $server {
        [$server_package]
      } else {
        []
      }
    ) +
    (
      if $client {
        [$client_package]
      } else {
        []
      }
    )
  ).unique

  package { $packages:
    ensure => $_version,
    tag    => 'gluster-packages',
  }

  if $server {
    Package[$server_package] ~> Class['gluster::service']
  }
}
