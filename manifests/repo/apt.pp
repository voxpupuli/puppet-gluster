# @summary enable the upstream Gluster Apt repo
# @api private
#
# @param version The version to use when building the repo URL
# @param release The release to use when building the repo URL
# @param priority
#   The priority for the apt/yum repository. Useful to overwrite other repositories like EPEL
#
# Currently only released versions are supported.  If you want to use
# QA releases or pre-releases, you'll need to edit line 54 below
#
# @example Enable the LATEST Apt repo for release 4.1
#   class { gluster::repo::apt:
#     version => 'LATEST',
#     release => '4.1',
#   }
#
# @example Enable the version 4.1.10 Apt repo for release 4.1
#   class { gluster::repo::apt:
#     version => '4.1.10',
#     release => '4.1',
#   }
#
# @author Drew Gibson <dgibson@rlsolutions.com>
# @note Copyright 2015 RL Solutions, unless otherwise noted
#
class gluster::repo::apt (
  $version,
  String[1] $release,
  $priority,
  Variant[Stdlib::Absolutepath,Stdlib::HTTPSUrl] $repo_key_source,
) {

  assert_private()

  include 'apt'

  $repo_key_name = $release ? {
    '4.1'        => 'EED3351AFD72E5437C050F0388F6CDEE78FA6D97',
    '^5\.(\d)+$' => 'F9C958A3AEE0D2184FAD1CBD43607F0DC2F8238C',
    /^6/         => 'F9C958A3AEE0D2184FAD1CBD43607F0DC2F8238C',
    /^7/         => 'F9C958A3AEE0D2184FAD1CBD43607F0DC2F8238C',
    default      => '849512C2CA648EF425048F55C883F50CB2289A17',
  }

  # basic sanity check
  if $version == 'LATEST' {
    $repo_ver = $version
  } elsif $version =~ /^\d\.\d+$/ {
    $repo_ver = "${version}/LATEST"
  } elsif $version =~ /^(\d)\.(\d+)\.(\d+).*$/ {
    $repo_ver =  "${1}.${2}/${1}.${2}.${3}"
  } else {
    fail("${version} doesn't make sense for ${::operatingsystem}!")
  }

  # the Gluster repo only supports x86_64 (amd64) and arm64. The Ubuntu PPA also supports armhf and arm64.
  case $facts['os']['name'] {
    'Debian': {
      $arch = $facts['architecture'] ? {
        'amd64' => 'amd64',
        'arm64' => 'arm64',
        default => false,
      }
      $repo_url  = "https://download.gluster.org/pub/gluster/glusterfs/${release}/LATEST/Debian/${facts['lsbdistcodename']}/${arch}/apt/"
    }
    default: {
      fail('gluster::repo::apt currently only works on Debian')
    }
  }
  if ! $arch {
    fail("Architecture ${facts['architecture']} not yet supported for ${facts['operatingsystem']}.")
  }

  $repo = {
    "glusterfs-${version}" => {
      ensure       => present,
      location     => $repo_url,
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
