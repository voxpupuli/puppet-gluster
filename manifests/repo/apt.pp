#
# == Class gluster::repo::apt
#
# enable the upstream Gluster Apt repo
#
# === Parameters
#
# version: the version to use when building the repo URL
#
# Currently only released versions are supported.  If you want to use
# QA releases or pre-releases, you'll need to edit line 54 below

# === Examples
#
# Enable the Apt repo, and use the public key
# 
# class { gluster::repo::apt: 
#   version => 'LATEST',
# }
#
# === Authors
#
# Scott Merrill <smerrill@covermymeds.com>
#
# === Copyright
#
# Copyright 2014 CoverMyMeds, unless otherwise noted
#
class gluster::repo::apt (
  $version = $::gluster::params::version,
) {

  include ::apt

  # basic sanity check
  if ! $version {
    fail ('Version not specified: unable to define repo!')
  }

  # Base url changed to http transport for compatibility with apt.
  # TODO: move parameters from here to params class.
  $repo_base = 'http://download.gluster.org/pub/gluster/glusterfs'
  if $version == 'LATEST' {
    $repo_ver = $version
  } else {
    if $version =~ /^\d\.\d$/ {
      $repo_ver = "${version}/LATEST"
    } elsif $version =~ /^(\d)\.(\d)\.(\d).*$/ {
      $repo_ver = "${1}.${2}/${1}.${2}.${3}"
    } else {
      fail("${version} doesn't make sense!")
    }
  }

  #http://download.gluster.org/pub/gluster/glusterfs/3.6/LATEST/Debian/wheezy/apt
  $repo_url = "${repo_base}/${repo_ver}/Debian/wheezy"
  
  apt::source { 'gluster':
    location   => "${repo_url}/apt",
    release    => 'wheezy',
    repos      => 'main',
    key        => '21C74DF2',
    key_source => "${repo_url}/pubkey.gpg",
  }

  Apt::Source['gluster'] -> Package <| tag == 'gluster-packages' |>

}
