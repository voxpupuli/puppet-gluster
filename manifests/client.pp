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
class gluster::client {
  include gluster
  class { 'gluster::install':
    server         => false,
    client         => true,
    repo           => $gluster::repo,
    version        => $gluster::version,
    client_package => $gluster::client_package,
  }
}
