# @summary enables an upstream GlusterFS repository
# @api private
#
# @note that this module is a wrapper for sub-classes that implement
#   the specific repository type, ie:  gluster::repo::yum
#
# @param version
#    the version of the upstream repo to enable
#
# @param priority
#   The priority for the apt/yum repository. Useful to overwrite other repositories like EPEL
#
# @param repo_key_source
#   HTTP Link or absolute path to the GPG key for the repository.
#
# @example
#   class { gluster::repo
#     version => '3.5.2',
#   }
#
# @author Scott Merrill <smerrill@covermymeds.com>
# @note Copyright 2014 CoverMyMeds, unless otherwise noted
#
class gluster::repo (
  $release,
  $version,
  Variant[Stdlib::Absolutepath,Stdlib::HTTPSUrl] $repo_key_source,
  Optional[Integer] $priority = undef,
) {

  assert_private()

  case $::osfamily {
    'RedHat': {
      class { 'gluster::repo::yum':
        release         => $release,
        priority        => $priority,
        repo_key_source => $repo_key_source,
      }
    }
    'Debian': {
      class { 'gluster::repo::apt':
        release         => $release,
        version         => $version,
        priority        => $priority,
        repo_key_source => $repo_key_source,
      }
    }
    default: { fail("${::osfamily} not yet supported!") }
  }
}
