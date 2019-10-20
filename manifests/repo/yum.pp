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
  String $release,
  Variant[Stdlib::Absolutepath,Stdlib::HTTPSUrl] $repo_key_source,
  Optional[Integer] $priority = undef,
) {

  assert_private()

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
