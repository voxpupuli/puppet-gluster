Puppet Gluster
==============

This module installs and configures servers to participate in a [Gluster](http://www.gluster.org/) Trusted Storage Pool, create or modify one or more Gluster volumes, and mount Gluster volumes.

Also provided with this module are a number of custom Gluster-related facts.

## Facts ##
* `gluster_peer_count`: the number of peers to which this server is connected in the pool.
* `gluster_peer_list`: a comma-separated list of peer hostnames
* `gluster_volume_list`: a comma-separated list of volumes being served by this server
* `gluster_volume_#{vol}_bricks`: a comma-separated list of bricks in each volume being served by this server

## Classes ##
### params.pp ###
This class establishes a number of default values used by the other classes.

### client.pp ###
This class installs the Gluster client package. Usually this is the `gluster-fuse` package.

### repo.pp ###
This class optionally enables the upstream Gluster.org repositories.  Currently, only the yum repo type is implemented. 

### init.pp ###
This class implements a basic Gluster server.  It exports a `gluster::server` defined type for itself, and then collects any other exporteed `gluster::server` resources for instantiation.

## Defines ##
### gluster::server ###
This defined type creates a Gluster peering relationship.  The name of the type should be the fully-qualified domain name of a peer to which to connect. An optional `pool` parameter permits you to configure different storage pools built from different hosts.

With the exported resource implementation in `init.pp`, the first server to be defined in the pool will find no peers, and therefore not do anything.  The second server to execute this module will collect the first server's exported resource and initiate the `gluster peer probe`, thus creating the storage pool.

Note that the server being probed does not perform any DNS resolution on the server doing the probing. This means that the probed client will report only the IP address of the probing server.  The next time the probed client runs this module, it will execute a `gluster peer probe` against the originally-probing server, thereby updating its list of peers to use the FQDN of the other server.
http://www.gluster.org/pipermail/gluster-users/2013-December/038354.html

### gluster::volume ###
This defined type creates a Gluster volume. You can specify a stripe count, a replica count, the transport type, and a list of bricks to use.

Note that creating brick filesystems is up to you. May I recommend the [Puppet Labs LVM module](https://forge.puppetlabs.com/puppetlabs/lvm) ?

