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
  $value  = undef,
  Enum['present', 'absent'] $ensure = 'present',
) {

  $arr = split( $title, ':' )
  $count = count($arr)
  # do we have more than one array element?
  if $count != 2 {
    fail("${title} does not parse as volume:option")
  }
  $vol = $arr[0]
  $opt = $arr[1]

  if $ensure == 'absent' {
    $cmd = "reset ${vol} ${opt}"
  } else {
    $cmd = "set ${vol} ${opt} ${value}"
  }

  exec { "gluster option ${vol} ${opt} ${value}":
    command => "${::gluster_binary} volume ${cmd}",
  }
}
