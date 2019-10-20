# @summary Ensure that the Gluster FUSE client package is installed
#
# @note This is a convenience class to ensure that *just* the client
#   is installed.  If you need both client and server, please use
#   the main gluster class
#
# @param repo
#   Whether to use the GlusterFS repository
# @param client_package
#   The name of the client package to install.
# @param version
#   The version of the client tools to install.
# @param repo_key_source
#   HTTP Link or absolute path to the GPG key for the repository.
#
# @example
#   class { gluster::client:
#     repo           => true,
#     client_package => 'glusterfs-fuse',
#     version        => 'LATEST',
#   }
#
# @author Scott Merrill <smerrill@covermymeds.com>
# @note Copyright 2014 CoverMyMeds, unless otherwise noted
#
#
class gluster::client (
  Boolean $repo             = $gluster::params::repo,
  String $client_package    = $gluster::params::client_package,
  String $version           = $gluster::params::version,
  String $release           = $gluster::params::release,
  Optional $repo_key_source = $gluster::params::repo_key_source,
) inherits gluster::params {

  # if we manage the repository, we also need a GPG key
  if $repo {
    assert_type(Variant[Stdlib::Absolutepath, Stdlib::HTTPSUrl], $repo_key_source)
  }

  class { 'gluster::install':
    server          => false,
    client          => true,
    repo            => $repo,
    version         => $version,
    client_package  => $client_package,
    release         => $release,
    repo_key_source => $repo_key_source,
  }
}
