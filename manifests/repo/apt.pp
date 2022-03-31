# @summary enable the upstream Gluster Apt repo
# @api private
#
# @param version The version to use when building the repo URL
# @param release The release to use when building the repo URL
# @param priority Apt pin priority to set for the Gluster repo
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
  $version  = $gluster::params::version,
  $release  = $gluster::params::release,
  $priority = $gluster::params::repo_priority,
) {
  include 'apt'

  $_release = versioncmp($release, '4.1') ? {
    1       => $release.match(/\A[^.]*/)[0],
    default => $release,
  }

  # the Gluster repo only supports x86_64 (amd64) and arm64. The Ubuntu PPA also supports armhf and arm64.
  case $facts['os']['name'] {
    'Debian': {
      $repo_key_name = $release ? {
        '3.9'   => '849512C2CA648EF425048F55C883F50CB2289A17',
        '3.10'  => 'C784DD0FD61E38B8B1F65E10DAD761554A72C1DF',
        '3.11'  => 'DE82F0BACC4DB70DBEF95CA65EC2255642304A6E',
        '3.12'  => '8B7C364430B66F0B084C0B0C55339A4C6A7BD8D4',
        '3.13'  => '9B5AE8E6FD2581F293104ACC38675E5F30F779AF',
        '4.0'   => '55F839E173AC06F364120D46FA86EEACB306CEE1',
        '4.1'   => 'EED3351AFD72E5437C050F0388F6CDEE78FA6D97',
        default => 'F9C958A3AEE0D2184FAD1CBD43607F0DC2F8238C',
      }

      $repo_key_source = "https://download.gluster.org/pub/gluster/glusterfs/${_release}/rsa.pub"

      # basic sanity check
      if $version == 'LATEST' {
        $repo_ver = $version
      } elsif $version =~ /^\d\.\d+$/ {
        $repo_ver = "${version}/LATEST"
      } elsif $version =~ /^(\d)\.(\d+)\.(\d+).*$/ {
        $repo_ver =  "${1}.${2}/${1}.${2}.${3}"
      } else {
        fail("${version} doesn't make sense for ${facts['os']['name']}!")
      }

      case $facts['os']['distro']['codename'] {
        'jessie', 'stretch':  {
          $arch = $facts['os']['architecture'] ? {
            'amd64'      => 'amd64',
            'arm64'      => 'arm64',
            default      => false,
          }

          $_repo_base = 'https://download.gluster.org/pub/gluster/glusterfs'
          $repo_url = if versioncmp($release, '4.1') < 0 {
            "${_repo_base}/01.old-releases/${release}/LATEST/Debian/${facts['os']['distro']['codename']}/${arch}/apt/"
          } else {
            "${_repo_base}/${_release}/LATEST/Debian/${facts['os']['distro']['codename']}/${arch}/apt/"
          }
        }
        default: {
          fail('unsupported distribution codename')
        }
      }
    }
    'Ubuntu': {
      $repo_key_name = 'F7C73FCC930AC9F83B387A5613E01B7B3FE869A9'
      $repo_key_source = undef

      unless $version == 'LATEST' {
        fail("Specifying version other than LATEST doesn't make sense for Ubuntu PPA!")
      }
      $repo_ver = $version

      $arch = $facts['os']['architecture'] ? {
        'amd64'      => 'amd64',
        'arm64'      => 'arm64',
        'armhf'      => 'armhf',
        'i386'       => 'i386',
        default      => false,
      }

      $repo_url = "http://ppa.launchpad.net/gluster/glusterfs-${_release}/ubuntu"
    }
    default: {
      fail('gluster::repo::apt currently only works on Debian and Ubuntu')
    }
  }

  unless $arch {
    fail("Architecture ${facts['os']['architecture']} not yet supported for ${facts['os']['name']}.")
  }

  $repo = {
    "glusterfs-${version}" => {
      ensure       => present,
      location     => $repo_url,
      release      => $facts['os']['distro']['codename'],
      repos        => 'main',
      key          => {
        id         => $repo_key_name,
        source     => $repo_key_source,
      },
      pin          => $priority,
      architecture => $arch,
    },
  }

  create_resources(apt::source, $repo)

  Apt::Source["glusterfs-${version}"] -> Package<| tag == 'gluster-packages' |>
}
