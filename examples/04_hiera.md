Gluster with Hiera
==================

This Gluster module makes it very easy to work with data stored in [Hiera](https://docs.puppetlabs.com/hiera/latest/).

Hiera's [automatic parameter lookup](https://docs.puppetlabs.com/hiera/latest/puppet.html#automatic-parameter-lookup) feature means that you can define common parameters a single time in your Hiera hierarchy and then have them automagically applied to your nodes.

Consider the following hiera.yaml:

    :yaml:
      :datadir: /etc/puppet/hieradata
    :hierarchy:
      - "hosts/%{::fqdn}"
      - "env/%{::app_env}"
      - common

Your `/etc/puppet/hieradata/common.yaml` file could then contain:

    ---
    gluster::client: true
    gluster::pool: production
    gluster::repo: true
    gluster::version: '3.5.2-1.el6'

You can then simply apply `class { ::gluster: }` to any hosts and they will use the upstream Gluster repo, install version 3.5.2-1.el6 of both the server and client, and join the `production` pool.

In this way, you could have two servers (srv1.local and srv2.local) operating in a different pool, with a different version of Gluster, and without the client packages installed, while all your other servers use the values from common.yaml.

/etc/puppet/hieradata/hosts/srv1.local.yaml:

    ---
    gluster::client: false
    gluster::pool: testing
    gluster::repo: true
    gluster::version: '3.6.1-1.el6'

/etc/puppet/hieradata/hosts/srv2.local.yaml:

    ---
    gluster::client: false
    gluster::pool: testing
    gluster::repo: true
    gluster::version: '3.6.1-1.el6'

If you support multiple major versions of Red Hat (and derivative) systems, you can still easily use Hiera data to define a common package version for all systems. Your `/etc/puppet/hieradata/common.yaml` file would then contain:

    ---
    gluster::client: true
    gluster::pool: production
    gluster::repo: true
    gluster::version: "3.5.2-1.el%{::operatingsystemmajrelease}"

Hiera will interepret the value of `%{::operatingsystemmajrelease}` as a fact of the same name, and replace the Red Hat major version number in this string.

If you would like to specify mounts in hiera, you can add items on `/etc/puppet/hieradata/common.yaml` or any other (more specific) layer:

    ---
    gluster_mounts:
      /mountpoint:
        volume: hostname:/volume
        ensure: mounted

  - /mountpoint should be replaced by the path where you would like this gluster resource to be mounted.
  - hostname should be replaced by the hostname/ip of the machine offering this gluster volume.
  - /volume should be replaced by the volume available on the gluster server.

To create these mounts, add a class to the host with this content:

    class profile::gluster {
      create_resources('gluster::mount', hiera_hash("gluster_mounts"), {})
    }

Mounts can be described in mutiple layers, hiera_hash will collect them and create_resources will make all mounts.
