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
# options: a hash of gluster::volume::`options for the volume
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
#   options => {
#                'server.allow-insecure' =>
#                  { 'value'             => 'on' },
#                }
#
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
  $stripe = false,
  $replica = false,
  $transport = 'tcp',
  $rebalance = true,
  $bricks = undef
  $options = undef,
) {
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
    validate_hash( $options )
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

      # don't forget to start the new volume!
      exec { "gluster start volume ${title}":
        command => "${binary} volume start ${title}",
        require => Exec["gluster create volume ${title}"],
      }

      # if we have volume options, activate them now
      if $options {
        $options_volume = {
          'volume' => $title,
        }
        create_resources(::gluster::volume::option, $options, $options_volume)
      }

    } else {
      # this volume exists

      # our fact lists bricks comma-separated, but we use them space-separated here
      $vol_bricks = regsubst( getvar( "::gluster_volume_${title}_bricks" ), ',', ' ', 'G')
      if $_bricks != $vol_bricks {
        # this resource's list of bricks does not match the existing
        # volume's list of bricks
        $vol_bricks_array = split($vol_bricks, ' ')
        $new_bricks = difference($bricks, $vol_bricks_array)

        $vol_count = count($vol_bricks_array)
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
      $current_options = get_var("gluster_volume_${title}_options")
      if $current_options != $options {
        # get a hash of the differences
        # and apply those
      }
    }
  }
}
