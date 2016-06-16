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

  # we explicitly do NOT set a priority here. The user must define
  # a priority in order to ensure that it is activated
  $repo_priority = undef
  $repo_base     = 'https://download.gluster.org/pub/gluster/glusterfs'

  # Set distro/release specific names, repo versions, repo gpg keys, package versions, etc
  # if the user didn't specify a version, just use "installed" for package version.
  # if they did specify a version, assume they provided a valid one
  case $::osfamily {
    'RedHat': {
      $repo_gpg_key_name = 'RPM-GPG-KEY-gluster.pub'
      $repo_gpg_key_path = '/etc/pki/rpm-gpg/'
      $repo_gpg_key_source = "puppet:///modules/${module_name}/${repo_gpg_key_name}"
      
      $server_package = $::operatingsystemmajrelease ? {
        # RHEL 6 and 7 provide Gluster packages natively
        /(6|7)/ => 'glusterfs',
        default => false
      }
      $client_package = $::operatingsystemmajrelease ? {
        /(6|7)/ => 'glusterfs-fuse',
        default => false,
      }
      $package_version = $version ? {
        'LATEST' => 'installed',
        default  => $version,
      }
      
      $service_name = 'glusterd'
    }
    'Debian': {
      $deb_name = "${::lsbdistcodename}"
      # Figure out the gpg public key for the repo
      case $::operatingsystem {
        'Ubuntu': {
          $repo_gpg_key_name = 'F7C73FCC930AC9F83B387A5613E01B7B3FE869A9'
          $package_version = $version ? {
            /^(\d)\.(\d)\.(\d).*$/ => "${version}",
            default                => 'installed',
          }
        }
        'Raspbian': {
          # gluster Raspbian repos seem to be signed with a variety of keys prior to 3.7.6
          case $deb_name {
            'wheezy': {
              case $version {
                '3.4.7', /^3\.[46]$/, /^3\.6\.[12]/: { $repo_gpg_key_name = '46B0B984B3722B5C0D4E929111B2C94621C74DF2' } # 1752
                default: { fail( "Repo unsupported for gluster version \"${version}\" on Raspbian release \"${deb_name}\"." ) }
              }
              $package_version = $version ? {
                '3.6'     => '3.6.2',
                'LATEST'  => '3.6.2',
                default   => "${version}",
              }
            }
            'jessie': {
              case $version { 
                '3.5.6', /^3\.[567]$/, '3.6.5', /^3\.7\.[34]/: { $repo_gpg_key_name = '591A0FD27E0F1CBA27C71B7DDDE45E094AB22BB3' } # 1748 
                default: { fail( "Repo unsupported for gluster version \"${version}\" on Raspbian release \"${deb_name}\".") }
              }
              $package_version = $version ? {
                '3.6'    => '3.6.5',
                '3.7'    => '3.7.4',
                'LATEST' => '3.7.4',
                default  => "${version}",
              }
            }
            default: {
              $repo_gpg_key_name = 'A4703C37D3F4DE7F1819E980FE79BB52D5DC52DC' # 1732
              $package_version = $version ? {
                'LATEST' => 'installed',
                default  => "${version}",
              }
            }
          }
        }
        default: {
        # 'Debian': {
          # gluster Debian repos seem to be signed with a variety of keys prior to 3.7.6
          case $deb_name {
            'wheezy':  {
              case $version {
                '3.3.1': {
                  $repo_gpg_key_name = '9BD4D907FA554FC8B4A3716F3730DD4989CCAE8B' # 9621
                }
                '3.3', '3.3.2', /^3\.[45].*/, /^3\.6\.[1-6]/: {
                  $repo_gpg_key_name = '46B0B984B3722B5C0D4E929111B2C94621C74DF2' # 1752
                }
                default: {
                  $repo_gpg_key_name = 'A4703C37D3F4DE7F1819E980FE79BB52D5DC52DC' # 1732
                }
              }
            }
            'jessie', 'stretch':  {
              case $version {
                /^3\.[456].*/, /^3\.7\.[0-5]/: {
                  $repo_gpg_key_name = '591A0FD27E0F1CBA27C71B7DDDE45E094AB22BB3' # 1748
                }
                default: {
                  $repo_gpg_key_name = 'A4703C37D3F4DE7F1819E980FE79BB52D5DC52DC' # 1732
                }
              }
            }
            default:   { $repo_gpg_key_name = 'A4703C37D3F4DE7F1819E980FE79BB52D5DC52DC' } # 1732
          }
          $package_version = $version ? {
            'LATEST' => 'installed',
            default  => "${version}",
          }
        }
      }
      $server_package  = 'glusterfs-server'
      $client_package = 'glusterfs-client'

      $service_name = 'glusterfs-server'
    }
    default: {
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
