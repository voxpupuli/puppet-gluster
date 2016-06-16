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
  $repo_url        = undef,
  $repo_key_name   = $::gluster::params::repo_gpg_key_name,
  $repo_key_path   = $::gluster::params::repo_gpg_key_path,
  $repo_key_source = $::gluster::params::repo_gpg_key_source,
  $priority        = $::gluster::params::repo_priority,
) {
  include 'apt'
  
 if $priority != undef {
   validate_hash( $priority )
 }
  
  $repo_base = "${::gluster::params::repo_base}"
  
  # basic sanity check
  if $version == 'LATEST' {
    $repo_ver = $::operatingsystem ? {
      'Ubuntu' => '3.7',
      default  => $version,
    }
  } else {
    if $version =~ /^\d\.\d$/ {
      $repo_ver = $::operatingsystem ? {
        'Ubuntu' => "${version}",
        default  => "${version}/LATEST",
      }
    } elsif $version =~ /^(\d)\.(\d)\.(\d).*$/ {
      $repo_ver = $::operatingsystem ? {
        'Ubuntu' => "${1}.${2}",
        default  => "${1}.${2}/${1}.${2}.${3}",
      }
    } else {
      fail("${version} doesn't make sense for $::operatingsystem!")
    }
  }
    
  # the Gluster repo only supports x86_64 and i386. armhf is only supported for Raspbian. The Ubuntu PPA also supports armhf and arm64.
  case $::operatingsystem {
    # default: {
    'Ubuntu': {
      $arch = $::architecture ? {
        'amd64'      => 'amd64',
        /i\d86/      => 'i386',
        /armv[67].*/ => 'armhf',
        /armv8.*/    => 'arm64',
        default      => false,
      }
      $default_repo_url  = "http://ppa.launchpad.net/gluster/glusterfs-${repo_ver}/ubuntu/"
      $keyserver = 'keyserver.ubuntu.com'   
    }
    default: {
      $arch = $::architecture ? {
        /armv[67].*/ => 'armhf',       # Raspbian
        'amd64'      => 'amd64',
        /i\d86/      => 'i386',
        default      => false,
      }
      $default_repo_url  = "${repo_base}/${repo_ver}/Debian/${::lsbdistcodename}/apt/"
      $keyserver = 'keyring.debian.org'   
    }
  }
  if ! $arch {
    fail("Architecture ${::architecture} not yet supported for ${::operatingsystem}.")
  }
  
  if $repo_url == undef {
    $_repo_url = $default_repo_url
  } else {
    validate_string( $repo_url )
    validate_re( $repo_url, [ '^http://.*', '^https://.*', '^ftp://.*', ] )
    $_repo_url = $repo_url
  }
  
  $repo = {
    "glusterfs-${version}" => {
      ensure       => present,
      location     => "${_repo_url}",
      release      => "${::lsbdistcodename}",
      repos        => 'main',
      key          => {
        id     => "${repo_key_name}",
        server => "${keyserver}",
      },
      pin          => $priority,
      architecture => "${arch}",
    },
  }
  
  create_resources(apt::source, $repo)
  
  Apt::Source["glusterfs-${version}"] -> Package<| tag == 'gluster-packages' |>

}
