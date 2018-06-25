# == Define: gluster::volume
#
# Create GlusterFS volumes, and maybe extend them
#
# === Parameters
#
# stripe: the stripe count to use for a striped volume
# replica: the replica count to use for a replica volume
# arbiter: the arbiter count to use for a replica volume
# transport: the transport to use. Defaults to tcp
# rebalance: whether to rebalance a volume when new bricks are added
# heal: whether to heal a replica volume when adding bricks
# bricks: an array of bricks to use for this volume
# options: an array of volume options for the volume
#          https://github.com/gluster/glusterfs/blob/master/doc/admin-guide/en-US/markdown/admin_managing_volumes.md#tuning-options
# remove_options: whether to permit the removal of active options that
#                 are not defined for this volume.  Default: false
#
# === Examples
#
# gluster::volume { 'storage1':
#   replica => 2,
#   bricks  => [
#                'srv1.local:/export/brick1/brick',
#                'srv2.local:/export/brick1/brick',
#                'srv1.local:/export/brick2/brick',
#                'srv2.local:/export/brick2/brick',
#   ],
#   options => [
#                'server.allow-insecure: on',
#                'nfs.ports-insecure: on',
#              ],
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
define gluster::volume (
  Array[String, 1] $bricks,

  Boolean $force                              = false,
  Enum['tcp', 'rdma', 'tcp,rdma'] $transport  = 'tcp',
  Boolean $rebalance                          = true,
  Boolean $heal                               = true,
  Boolean $remove_options                     = false,
  Array[Pattern[/.+:.+/]] $options            = [],
  Optional[Integer] $stripe                   = undef,
  Optional[Integer] $replica                  = undef,
  Optional[Integer] $arbiter                  = undef,
) {

  if $force {
    $_force = 'force'
  } else {
    $_force = ''
  }

  if $stripe {
    $_stripe = "stripe ${stripe}"
  } else {
    $_stripe = ''
  }

  if $replica {
    $_replica = "replica ${replica}"
  } else {
    $_replica = undef
  }

  $_transport = "transport ${transport}"

  if $arbiter {
    $_arbiter = "arbiter ${arbiter}"
  } else {
    $_arbiter = ''
  }

  $_bricks = join( $bricks, ' ' )

  $cmd_args = [
    $_stripe,
    $_replica,
    $_arbiter,
    $_transport,
    $_bricks,
    $_force,
  ]

  $args = join(delete($cmd_args, ''), ' ')

  if getvar('::gluster_binary'){
    # we need the Gluster binary to do anything!

    $already_exists = getvar('::gluster_volume_list') and $title in split($::gluster_volume_list, ',')

    exec { "gluster create volume ${title}":
      command => "${::gluster_binary} volume create ${title} ${args}",
      unless  => $already_exists,
    }
    -> exec { "gluster start volume ${title}":
      command => "${::gluster_binary} volume start ${title}",
      unless  => $already_exists,
    }

    # did the options change?
    $current_options = getvar("gluster_volume_${title}_options")
    if $current_options {
      $_current_options = split($current_options, ',')
    } else {
      $_current_options = []
    }

    $options_to_remove = $_current_options - $options
    $options_to_add = $options - $_current_options

    if $remove_options {
      # TODO: What if an option value changed? It'll probably be in $options_to_remove
      $options_to_remove.each |$option| {
        $split_option = split($option, ':')
        $option_name = strip($split_option[0])
        gluster::volume::option { "${title}:${option_name}":
          ensure => absent,
        }
      }
    } elsif ! empty($options_to_remove) {
      $remove_str = join($options_to_remove.map |$opt| { strip(split($opt)[0]) }, ', ')
      notice("NOT REMOVING the following options for volume ${title}:${remove_str}.")
    }

    # if we have volume options, activate them now. $options is an array of
    # strings with option: value so we have to unpack that first.
    $options_to_add.each |$option| {
      $split_option = split($option, ':')
      $option_name = strip($split_option[0])
      gluster::volume::option { "${title}:${option_name}":
        ensure  => present,
        value   => strip($split_option[1]),
        require => Exec["gluster create volume ${title}"],
        before  => Exec["gluster start volume ${title}"],
      }
    }

    if $already_exists {
      # our fact lists bricks comma-separated, but we need an array
      $vol_bricks = split( getvar( "::gluster_volume_${title}_bricks" ), ',')
      if $bricks != $vol_bricks {
        # this resource's list of bricks does not match the existing
        # volume's list of bricks
        $new_bricks = difference($bricks, $vol_bricks)

        $vol_count = count($vol_bricks)
        if count($bricks) > $vol_count {
          # adding bricks

          # if we have a stripe or replica volume, make sure the
          # number of bricks to add is a factor of that value
          if $stripe {
            if ( count($new_bricks) % $stripe ) != 0 {
              fail("Number of bricks to add is not a multiple of stripe count ${stripe}")
            }
            $s = "stripe ${stripe}"
          } else {
            $s = ''
          }

          if $replica {
            if $arbiter and $arbiter != 0 {
              $r = "replica ${replica} arbiter ${arbiter}"
            } else {
              if ( count($bricks) % $replica ) != 0 {
                fail("Number of bricks to add is not a multiple of replica count ${replica}")
              }
              $r = "replica ${replica}"
            }
          } else {
            $r = ''
          }

          $new_bricks_list = join($new_bricks, ' ')
          exec { "gluster add bricks to ${title}":
            command => "${::gluster_binary} volume add-brick ${title} ${s} ${r} ${new_bricks_list} ${_force}",
          }

          if $rebalance {
            exec { "gluster rebalance ${title}":
              command => "${::gluster_binary} volume rebalance ${title} start",
              require => Exec["gluster add bricks to ${title}"],
            }
          }

          if $replica and $heal {
          # there is a delay after which a brick is added before
          # the self heal daemon comes back to life.
          # as such, we sleep 5 here before starting the heal
            exec { "gluster heal ${title}":
              command => "/bin/sleep 5; ${::gluster_binary} volume heal ${title} full",
              require => Exec["gluster add bricks to ${title}"],
            }
          }

        } elsif count($bricks) < $vol_count {
          # removing bricks
          notify{ 'removing bricks is not currently supported.': }
        } else {
          notify{ "unable to resolve brick changes for Gluster volume ${title}!\nDefined: ${_bricks}\nCurrent: ${vol_bricks}": }
        }
      }
    }
  }
}
