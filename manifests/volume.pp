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
  $stripe         = false,
  $replica        = false,
  $transport      = 'tcp',
  $rebalance      = true,
  $bricks         = undef,
  $options        = undef,
  $remove_options = false,
) {

  # we'll likely use this later
  $options_volume = {
    'volume' => $title,
  }

  # basic sanity checking
  if $stripe {
    if ! is_integer( $stripe ) {
      fail("Stripe value ${stripe} is not an integer")
    } else {
      $_stripe = "stripe ${stripe}"
    }
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
    "${_stripe}",
    "${_replica}",
    "${_transport}",
    "${_bricks}",
  ]

  $args = join(delete($cmd_args, ''), ' ')

  $binary = $::gluster_binary
  if $binary{
    # we need the Gluster binary to do anything!

    if ! member( split( $::gluster_volume_list, ',' ), $title ) {
      # this volume has not yet been created
      exec { "gluster create volume ${title}":
        command => "${binary} volume create ${title} ${args}",
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
        $yaml = join( regsubst( $_options, ': ', ":\n  value: ", G), "\n")
        $hoh = parseyaml($yaml)

        # safety check
        validate_hash($hoh)

        create_resources(::gluster::volume::option, $hoh, $options_volume)
      }

      # don't forget to start the new volume!
      exec { "gluster start volume ${title}":
        command => "${binary} volume start ${title}",
        require => Exec["gluster create volume ${title}"],
      }

    } else {
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
              fail("Number of bricks to add is not a multiple of stripe count ${stipe}")
            }
          }
          if $replica {
            if ( count($new_bricks) % $replica ) != 0 {
              fail("Number of bricks to add is not a multiple of replica count ${replica}")
            }
          }

          $new_bricks_list = join($new_bricks, ' ')
          exec { "gluster add bricks to ${title}":
            command => "${binary} volume add-brick ${title} ${new_bricks_list}",
          }

          if $rebalance {
            exec { "gluster rebalance ${title}":
              command => "${binary} volume rebalance ${title} start",
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
      $current_options = sort( split(getvar("gluster_volume_${title}_options"), ',') )
      if $current_options != $_options {
        #
        # either of $current_options or $_options may be empty.
        # we need to account for this situation
        #
        if is_array($current_options) and is_array($_options) {
          $to_remove = difference($current_options, $_options)
          $to_add = difference($_options, $current_options)
        } else {
          if is_array($current_options) {
            # $_options is not an array, so remove all currently set options
            $to_remove = $current_options
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
          $remove_yaml = join( regsubst( $to_remove, ': .+$', ":\n  remove: true", G ), "\n" )
          $remove = parseyaml($remove_yaml)
          if $remove_options {
            create_resources( ::gluster::volume::option, $remove, $options_volume )
          } else {
            $r = join( keys($remove), ', ' )
            notice("NOT REMOVING the following options for volume ${title}: ${r}.")
          }
        }
        if ! empty($to_add) {
          # we have some options defined that are not active. Add them
          $add_yaml = join( regsubst( $to_add, ': ', ":\n  value: ", G ), "\n" )
          $add = parseyaml($add_yaml)
          create_resources( ::gluster::volume::option, $add, $options_volume )
        }
      }
    }
  }
}
