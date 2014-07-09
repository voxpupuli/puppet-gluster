class gluster::repo inherits ::gluster::params
{
  if $repo {
    case $::osfamily {
      'RedHat': { include gluster::repo::rpm }
      default: { fail("${::osfamily} not yet supported!") }
    }
  }
}
