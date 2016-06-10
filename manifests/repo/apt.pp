#
# == Class gluster::repo::apt
#
# enable the upstream Gluster Apt repo
#
# === Parameters
#
# version: the version to use when building the repo URL
# repo_key_name: The repo signing key or fingerprint
# repo_key_path: ignored
# repo_key_source: ignored
# priority: Apt pin priority to set for the Gluster repo
#
# Currently only released versions are supported.  If you want to use
# QA releases or pre-releases, you'll need to edit line 54 below

# === Examples
#
# Enable the Apt repo, and use the public key supplied
#
# class { gluster::repo::apt:
#   repo_key_name => 'F7C73FCC930AC9F83B387A5613E01B7B3FE869A9',
# }
#
# === Authors
#
# Drew Gibson <dgibson@rlsolutions.com>
#
# === Copyright
#
# Copyright 2015 RL Solutions, unless otherwise noted
#
class gluster::repo::apt (
  $version         = $::gluster::params::version,
  $repo_key_name   = $::gluster::params::repo_gpg_key_name,
  $repo_key_source = $::gluster::params::repo_gpg_key_source,
  $priority        = $::gluster::params::repo_priority,
) {
  include '::apt'

  # basic sanity check
  if $version == 'LATEST' {
    $repo_ver = $version
  } else {
    if $version =~ /^\d\.\d$/ {
      $repo_ver = "${version}/LATEST"
    } elsif $version =~ /^(\d)\.(\d)\.(\d).*$/ {
      $repo_ver =  "${1}.${2}/${1}.${2}.${3}"
    } else {
      fail("${version} doesn't make sense for ${::operatingsystem}!")
    }
  }

  # the Gluster repo only supports x86_64 and i386. armhf is only supported for Raspbian. The Ubuntu PPA also supports armhf and arm64.
  case $::operatingsystem {
    'Debian': {
      case $::lsbdistcodename {
        'jessie', 'stretch':  {
          $arch = $::architecture ? {
            'amd64'      => 'amd64',
            /i\d86/      => 'i386',
            default      => false,
          }
          $repo_url  = "http://download.gluster.org/pub/gluster/glusterfs/${repo_ver}/Debian/${::lsbdistcodename}/apt/"
        }
      }
    }
    default: {
      fail('gluster::repo::apt currently only works on Debian')
    }
  }
  if ! $arch {
    fail("Architecture ${::architecture} not yet supported for ${::operatingsystem}.")
  }

  $repo = {
    "glusterfs-${version}" => {
      ensure       => present,
      location     => $repo_url,
      release      => $::lsbdistcodename,
      repos        => 'main',
      key          => {
        id         => $repo_key_name,
        key_source => $repo_key_source,
      },
      pin          => $priority,
      architecture => $arch,
    },
  }

  create_resources(apt::source, $repo)

  Apt::Source["glusterfs-${version}"] -> Package<| tag == 'gluster-packages' |>

}
