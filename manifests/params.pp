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
  $version = 'LATEST'

  # we explicitly do NOT set a priority here. The user must define
  # a priority in order to ensure that it is activated
  $repo_priority = undef

  # Set distro/release specific names, repo versions, repo gpg keys, package versions, etc
  # if the user didn't specify a version, just use "installed" for package version.
  # if they did specify a version, assume they provided a valid one
  case $::osfamily {
    'RedHat': {
      $repo                 = true
      $repo_gpg_key_name    = 'RPM-GPG-KEY-gluster.pub'
      $repo_gpg_key_path    = '/etc/pki/rpm-gpg/'
      $repo_gpg_key_source  = "puppet:///modules/${module_name}/${repo_gpg_key_name}"

      $server_package = $::operatingsystemmajrelease ? {
        # RHEL 6 and 7 provide Gluster packages natively
        /(6|7)/ => 'glusterfs',
        default => false
      }
      $client_package = $::operatingsystemmajrelease ? {
        /(6|7)/ => 'glusterfs-fuse',
        default => false,
      }

      $service_name = 'glusterd'
    }
    'Debian': {
      $repo                 = true
      $repo_gpg_key_name    = 'A4703C37D3F4DE7F1819E980FE79BB52D5DC52DC'
      $repo_gpg_key_source  = 'https://download.gluster.org/pub/gluster/glusterfs/LATEST/rsa.pub'

      $server_package = 'glusterfs-server'
      $client_package = 'glusterfs-client'

      $service_name = 'glusterfs-server'
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

  # parameters dealing with bricks

  # parameters dealing with volumes
}
