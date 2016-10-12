#
# == Class gluster::repo::yum
#
# enable the upstream Gluster Yum repo
#
# === Parameters
#
# release: GlusterFS release, such as 3.6, 3.7 or 3.8 (specific package defined with 'gluster::version')
# repo_key_name: the filename of this repo's GPG key
# repo_key_path: the path to this repo's GPG key on the target system
# repo_key_source: where to find this repo's GPG key
# priority: YUM priority to set for the Gluster repo
#
# Currently only released versions are supported.  If you want to use
# QA releases or pre-releases, you'll need to edit line 47

# === Authors
#
# Scott Merrill <smerrill@covermymeds.com>
#
# === Copyright
#
# Copyright 2014 CoverMyMeds, unless otherwise noted
#
class gluster::repo::yum (
  $release         = $::gluster::params::release,
  $repo_key_source = $::gluster::params::repo_gpg_key_source,
  $priority        = $::gluster::params::repo_priority,
) inherits ::gluster::params {

  # CentOS Gluster repo only supports x86_64
  if $::architecture != 'x86_64' {
    fail("Architecture ${::architecture} not yet supported for ${::operatingsystem}.")
  }

  if $priority {
    if ! defined( Package['yum-plugin-priorities'] ) {
      package { 'yum-plugin-priorities':
        ensure => installed,
        before => Yumrepo["glusterfs-${::architecture}"],
      }
    }
  }

  yumrepo { "glusterfs-${::architecture}":
    enabled  => 1,
    baseurl  => "http://mirror.centos.org/centos/${::operatingsystemmajrelease}/storage/${::architecture}/gluster-${release}/",
    descr    => "CentOS-${::operatingsystemmajrelease} - Gluster ${release}",
    gpgcheck => 1,
    gpgkey   => $repo_key_source,
    priority => $priority,
  }

  Yumrepo["glusterfs-${::architecture}"] -> Package<| tag == 'gluster-packages' |>

}
