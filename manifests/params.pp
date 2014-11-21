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

  # by default, we'll use the upstream repository
  $repo    = true
  $repo_gpg_key_name = 'RPM-GPG-KEY-gluster.pub'
  $repo_gpg_key_path = '/etc/pki/rpm-gpg/'
  $repo_gpg_key_source = "puppet:///modules/${module_name}/${repo_gpg_key_name}"
  # we explicitly do NOT set a priority here. The user must define
  # a priority in order to ensure that it is activated
  $repo_priority = false

  # these packages are the upstream names
  $server_package = 'glusterfs-server'
  $client_package = 'glusterfs-fuse'

  # and these packages are vendor-defined names
  if $::osfamily == 'RedHat' {
    $vendor_server_package = $::operatingsystemmajrelease ? {
      # RHEL 6 and 7 provide Gluster packages natively
      /(6|7)/ => 'glusterfs',
      default => false
    }
    $vendor_client_package = $::operatingsystemmajrelease ? {
      /(6|7)/ => 'glusterfs-fuse',
      default => false,
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
