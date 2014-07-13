# install the Gluster packages
#
class gluster::install (
  $install_server = $::gluster::params::install_server,
  $install_client = $::gluster::params::instalL_client,
  $server_package = $::gluster::params::server_package,
  $client_package = $::gluster::params::client_package,
  $repo           = $::gluster::params::repo,
  $version        = $::gluster::params::version,
) inherits ::gluster::params {
  if $repo {
    require ::gluster::repo
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
    }
  }

}
