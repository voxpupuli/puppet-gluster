# @summary enable the upstream Gluster Yum repo
# @api private
#
# @param release
#    GlusterFS release, such as 3.6, 3.7 or 3.8 (specific package defined with 'gluster::version')
# @param repo_key_source
#    where to find this repo's GPG key
# @param priority
#    YUM priority to set for the Gluster repo
#
# @note Currently only released versions are supported. If you want to use
#   QA releases or pre-releases, you'll need to edit line 47
#
# @author Scott Merrill <smerrill@covermymeds.com>
# @note Copyright 2014 CoverMyMeds, unless otherwise noted
#
class gluster::repo::yum (
  String $release = lookup('gluster::release',String, deep),
  String $repo_key_source = lookup('gluster::repo_gpg_key_source',String, deep),
  Optional[String] $priority = lookup('gluster::repo_priority',String, deep),
) {
  # CentOS Gluster repo only supports x86_64
  if $facts['os']['architecture'] != 'x86_64' {
    fail("Architecture ${facts['os']['architecture']} not yet supported for ${facts['os']['name']}.")
  }

 $var = versioncmp("${facts['os']['release']['major']}",'7')
  notify{"${facts['os']['release']['major']} -/- $var ":}
  if versioncmp("${facts['os']['release']['major']}",'7') >= 0 {
    if ! defined( Package['yum-plugin-priorities']) {
      package { 'yum-plugin-priorities':
        ensure => installed,
        before => Yumrepo["glusterfs-${facts['os']['architecture']}"],
      }
    }
  }

  $_release = if versioncmp($release, '4.1') <= 0 {
    $release
  } else {
    $release[0]
  }

  yumrepo { "glusterfs-${facts['os']['architecture']}":
    enabled  => 1,
    baseurl  => "http://mirror.centos.org/centos/${facts['os']['release']['major']}/storage/${facts['os']['architecture']}/gluster-${_release}/",
    descr    => "CentOS-${facts['os']['release']['major']} - Gluster ${_release}",
    gpgcheck => 1,
    gpgkey   => $repo_key_source,
    priority => $priority,
  }

  Yumrepo["glusterfs-${facts['os']['architecture']}"] -> Package<| tag == 'gluster-packages' |>
}
