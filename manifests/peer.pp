# == Define: gluster::peer
#
# Connects to a Gluster peer. Intended to be exported by each member of
# a Gluster Trusted Storage Pool. Each server should also collect all
# such exported resources for local realization.
#
# If the title of the exported resource is NOT the FQDN of the host
# on which the resource is being realized, then try to initiate a
# Gluster peering relationship.
#
# === Pamameters
#
# pool: the name of the storage pool to which this server should be assigned.
#
# === Examples
#
# Export this host's gluster::peer resource, and then collect all others:
# @@gluster::peer { $::fqdn:
#   pool => 'production',
# }
# Gluster::Peer <<| pool == 'production' |>>
#
# You can also explicitly define peers:
# gluster::peer { 'gluster1.example.com':
#   pool => 'pool1',
# }
#
# === Authors
#
# Scott Merrill <smerrill@covermymeds.com>
#
# === Copyright
#
# Copyright 2014 CoverMyMeds, unless otherwise notes
#
#
# Note: http://www.gluster.org/pipermail/gluster-users/2013-December/038354.html
#       When server-a probes server-b, server-b will only record the IP address
#       for server-a.  When server-b next runs Puppet, it will probe server-a
#       because server-a's fqdn is not in the list of peers. The peering will
#       have been successfully established the first time, so this second
#       peering attempt only resolves a cosmetic issue, not a functional one.
#
define gluster::peer (
  $pool = 'default'
) {

  # we can't do much without the Gluster binary
  # but we don't necessarily want the Puppet run to fail if the
  # gluster_binary fact is absent!
  if getvar('::gluster_binary') {
    # we can't join to ourselves, so it only makes sense to operate
    # on other gluster servers in the same pool
    if $title != $::fqdn {

      # and we don't want to attach a server that is already a member
      # of the current pool
      if getvar('::gluster_peer_list') {
        $peers = $::gluster_peer_list
        if ! member($peers, $title) {
          $already_in_pool = false
        } else {
          $already_in_pool = true
        }
      } else {
        $already_in_pool = false
      }
      if !$already_in_pool {
        exec { "gluster peer probe ${title}":
            command => "${::gluster_binary} peer probe ${title}",
          }
      }
    }
  }
}
