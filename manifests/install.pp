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
  Boolean $server        = lookup('gluster::install_server',String, deep),
  Boolean $client        = lookup('gluster::install_client',String, deep),
  Boolean $repo          = lookup('gluster::repo',String, deep),
  String $version        = lookup('gluster::version',String, deep),
  String $server_package = lookup('gluster::server_package',String, deep),
  String $client_package = lookup('gluster::client_package',String, deep),
) {
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

  if $client_package == $server_package {
    if $server {
      # we use ensure_packages here because on some distributions the client and server package have different names
      ensure_packages($server_package,
        {
          ensure => $_version,
          tag    => 'gluster-packages',
          notify => Class['gluster::service'],
        }
      )
    } elsif $client {
      ensure_packages($client_package,
        {
          ensure => $_version,
          tag    => 'gluster-packages',
        }
      )
    }
  } else {
    if $client {
      # we use ensure_packages here because on some distributions the client and server package have different names
      ensure_packages($client_package,
        {
          ensure => $_version,
          tag    => 'gluster-packages',
        }
      )
    }

    if $server {
      # we use ensure_packages here because on some distributions the client and server package have different names
      ensure_packages($server_package,
        {
          ensure => $_version,
          notify => Class['gluster::service'],
          tag    => 'gluster-packages',
        }
      )
    }
  }
}
