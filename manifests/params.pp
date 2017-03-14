#
# == Class gluster::params
#
# establishes various defaults for use in other gluster manifests
#
# === Parameters
#
# None!
#
# === Examples
#
# None!  This class should not be called in your manifests.
#
# === Authors
#
# Scott Merrill <smerrill@covermymeds.com>
#
# === Copyright
#
# Copyright 2014 CoverMyMeds, unless otherwise noted
#
class gluster::params {

  # parameters dealing with installation
  $install_server = true
  $install_client = true
  $release        = '3.8'
  $version        = 'LATEST'

  # we explicitly do NOT set a priority here. The user must define
  # a priority in order to ensure that it is activated
  $repo_priority = undef

  # Set distro/release specific names, repo versions, repo gpg keys, package versions, etc
  # if the user didn't specify a version, just use "installed" for package version.
  # if they did specify a version, assume they provided a valid one
  case $::osfamily {
    'RedHat': {
      $repo                 = true
      $repo_gpg_key_source  = 'https://raw.githubusercontent.com/CentOS-Storage-SIG/centos-release-storage-common/master/RPM-GPG-KEY-CentOS-SIG-Storage'

      $server_package = $::operatingsystemmajrelease ? {
        # RHEL 6 and 7 provide Gluster packages natively
        /(6|7)/ => 'glusterfs-server',
        default => false
      }
      $client_package = $::operatingsystemmajrelease ? {
        /(6|7)/ => 'glusterfs-fuse',
        default => false,
      }

      $service_name = 'glusterd'
    }
    'Debian': {
      $repo           = true
      $server_package = 'glusterfs-server'
      $client_package = 'glusterfs-client'
      $service_name   = 'glusterfs-server'
    }
    'Archlinux': {
      $repo = false
      $server_package = 'glusterfs'
      $client_package = 'glusterfs'
      $service_name   = 'glusterd'
    }
    default: {
      $repo = false
      # these packages are the upstream names
      $server_package = 'glusterfs-server'
      $client_package = 'glusterfs-fuse'

      $service_name = 'glusterfs-server'
    }
  }


  # parameters dealing with a Gluster server instance
  $service_enable = true
  $service_ensure = true
  $pool = 'default'
  $export_resources = true

  # this is how we identify ourselfes in case of multihome
  $identity = $::fqdn

  # parameters dealing with bricks

  # parameters dealing with volumes
}
