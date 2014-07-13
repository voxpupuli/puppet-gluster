class gluster  (
  $install_server = $::gluster::params::install_server,
  $install_client = $::gluster::params::instalL_client,
  $server_package = $::gluster::params::server_package,
  $client_package = $::gluster::params::client_package,
  $repo           = $::gluster::params::repo,
  $version        = $::gluster::params::version,
  $pool           = $::gluster::params::pool,
  $volumes        = undef,
) inherits ::gluster::params {

  include ::gluster::install
  include ::gluster::service

  # first we export this server's instance
  @@gluster::server { $::fqdn:
    pool => $pool,
  }

  # then we collect all instances
  Gluster::Server <<| pool == $pool |>>

  if $volumes {
    validate_hash( $volumes )
    create_resources( gluster::volume, $volumes )
  }
}
