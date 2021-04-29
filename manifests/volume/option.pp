# @summary set or remove a Gluster volume option
#
# @param title
#    the name of the volume, a colon, and the name of the option
# @param value
#    the value to set for this option
# @param ensure
#    whether to set or remove an option
#
# @example
#   gluster::volume::option { 'gv0:nfs.disable':
#     value  => 'on',
#   }
#
# @example
#   gluster::volume::option { 'gv0:server.allow-insecure':
#     value  => 'on',
#   }
#
# @example To remove a previously-set option:
#   gluster::volume::option { 'gv0:feature.read-only':
#     ensure => absent,
#   }
#
# @author Scott Merrill <smerrill@covermymeds.com>
# @note Copyright 2014 CoverMyMeds, unless otherwise noted
#
define gluster::volume::option (
  Optional[Variant[Boolean, String, Numeric]] $value  = undef,
  Enum['present', 'absent']                   $ensure = 'present',
  Optional[Boolean] $force_binary = false,
) {

  if($force_binary) {
    $real_binary = getvar('::gluster_binary') ? {
      String  => getvar('::gluster_binary'),
      default => lookup('gluster::gluster_binary',String,deep)
    }
  } else {
    $real_binary = getvar('::gluster_binary')
  }

  $arr = split( $title, ':' )
  $count = count($arr)
  # do we have more than one array element?
  if $count != 2 {
    fail("${title} does not parse as volume:option")
  }
  $vol = $arr[0]
  $opt = $arr[1]

  $cmd = if $ensure == 'absent' {
    "reset ${vol} ${opt}"
  } else {
    "set ${vol} ${opt} ${value}"
  }

  $_value = $value ? {
    Boolean => if $value {
      'on'
    } else {
      'off'
    },
    default => $value,
  }

  exec { "gluster option ${vol} ${opt} ${_value}":
    command => "${real_binary} volume ${cmd}",
  }
}
