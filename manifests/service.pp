# manage the glusterd service
class gluster::service (
  $ensure = $::gluster::params::service_enable
) inherits ::gluster::params {

  service { 'glusterd':
    ensure     => $ensure,
    hasrestart => true,
    hasstatus  => true,
  }
}
