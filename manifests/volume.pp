# == Define: gluster::volume
#
# Create GlusterFS volumes, and maybe extend them
#
# === Parameters
#
# stripe: the stripe count to use for a striped volume
# replica: the replica count to use for a replica volume
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
  $force          = false,
  $stripe         = false,
  $replica        = false,
  $transport      = 'tcp',
  $rebalance      = true,
  $heal           = true,
  $bricks         = undef,
  $options        = undef,
  $remove_options = false,
  $identity       = $gluster::params::identity,
) {

  # basic sanity checking
  if str2bool($force) {
    $_force = 'force'
  } else {
    $_force = ''
  }

  if $stripe {
    if ! is_integer( $stripe ) {
      fail("Stripe value ${stripe} is not an integer")
    }
    $_stripe = "stripe ${stripe}"
  } else {
    $_stripe = ''
  }

  if $replica {
    if ! is_integer( $replica ) {
      fail("Replica value ${replica} is not an integer")
    } else {
      $_replica = "replica ${replica}"
    }
  }

  if ! member( ['tcp', 'rdma', 'tcp,rdma'], $transport ) {
    fail("Invalid transport ${transport}")
  } else {
    $_transport = "transport ${transport}"
  }

  if $options {
    validate_array( $options )
    $_options = sort( $options )
  }

  validate_array( $bricks )
  $_bricks = join( $bricks, ' ' )

  $cmd_args = [
    $_stripe,
    $_replica,
    $_transport,
    $_bricks,
    $_force,
  ]

  $args = join(delete($cmd_args, ''), ' ')

  if getvar('::gluster_binary'){
    # we need the Gluster binary to do anything!

    if getvar('::gluster_peer_list') {
      $minimal_requirements = true
    } else {
      $minimal_requirements = false
    }

    if getvar('::gluster_volume_list') and member( split( $::gluster_volume_list, ',' ), $title ) {
      $already_exists = true
    } else {
      $already_exists = false
    }

    if $minimal_requirements and $already_exists == false {
      # this volume has not yet been created

      # before we can create it, we need to ensure that all the
      # servers hosting bricks are members of the storage pool
      #
      # first, get a list of unique server names hosting bricks
      $brick_hosts = unique( regsubst( $bricks, '^([^:]+):(.+)$', '\1') )
      # now get a list of all peers, including ourself
      $pool_members = concat( split( $::gluster_peer_list, ','), [ $identity ] )
      # now see what the difference is
      $missing_bricks = difference( $brick_hosts, $pool_members)

      if ! empty($missing_bricks) {
        notice("Not creating Gluster volume ${title}: some bricks are not in the pool")
      } else {
        exec { "gluster create volume ${title}":
          command => "${::gluster_binary} volume create ${title} ${args}",
        }

        # if we have volume options, activate them now
        #
        # Note: $options is an array, but create_resources requires
        #       a hash of hashes.  We do some contortions to get the
        #       array into the hash of hashes that looks like:
        #
        #       option.name:
        #         value: value
        #
        # Note 2: we're using the $_options variable, which contains the
        #         sorted list of options.
        if $_options {
          # first we need to prefix each array element with the volume name
          # so that we match the gluster::volume::option title format of
          #  volume:option
          $vol_opts = prefix( $_options, "${title}:" )
          # now we make some YAML, and then parse that to get a Puppet hash
          $yaml = join( regsubst( $vol_opts, ': ', ":\n  value: ", 'G'), "\n")
          $hoh = parseyaml($yaml)

          # safety check
          validate_hash($hoh)
          # we need to ensure that these are applied AFTER the volume is created
          # but BEFORE the volume is started
          $new_volume_defaults = {
            require => Exec["gluster create volume ${title}"],
            before  => Exec["gluster start volume ${title}"],
          }

          create_resources(::gluster::volume::option, $hoh, $new_volume_defaults)
        }

        # don't forget to start the new volume!
        exec { "gluster start volume ${title}":
          command => "${::gluster_binary} volume start ${title}",
          require => Exec["gluster create volume ${title}"],
        }
      }

    } elsif $already_exists {
      # this volume exists

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
            if ( count($bricks) % $replica ) != 0 {
              fail("Number of bricks to add is not a multiple of replica count ${replica}")
            }
            $r = "replica ${replica}"
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

      # did the options change?
      $current_options = getvar("gluster_volume_${title}_options")
      if $current_options {
        $_current = sort( split($current_options, ',') )
      } else {
        $_current = []
      }
      if $_current != $_options {
        #
        # either of $current_options or $_options may be empty.
        # we need to account for this situation
        #
        if is_array($_current) and is_array($_options) {
          $to_remove = difference($_current, $_options)
          $to_add = difference($_options, $_current)
        } else {
          if is_array($_current) {
            # $_options is not an array, so remove all currently set options
            $to_remove = $_current
          } elsif is_array($_options) {
            # $current_options is not an array, so add all our defined options
            $to_add = $_options
          }
        }
        if ! empty($to_remove) {
          # we have some options active that are not defined here. Remove them
          #
          # the syntax to remove ::gluster::volume::options is a little different
          # so build up the hash correctly
          #
          $remove_opts = prefix( $to_remove, "${title}:" )
          $remove_yaml = join( regsubst( $remove_opts, ': .+$', ":\n  ensure: absent", 'G' ), "\n" )
          $remove = parseyaml($remove_yaml)
          if $remove_options {
            create_resources( ::gluster::volume::option, $remove )
          } else {
            $remove_str = join( keys($remove), ', ' )
            notice("NOT REMOVING the following options for volume ${title}:${remove_str}.")
          }
        }
        if ! empty($to_add) {
          # we have some options defined that are not active. Add them
          $add_opts = prefix( $to_add, "${title}:" )
          $add_yaml = join( regsubst( $add_opts, ': ', ":\n  value: ", 'G' ), "\n" )
          $add = parseyaml($add_yaml)
          create_resources( ::gluster::volume::option, $add )
        }
      }
    }
  }
}
