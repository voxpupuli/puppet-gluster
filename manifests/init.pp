class gluster  (
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
    create_resources( ::gluster::volume, $volumes )
  }
}
