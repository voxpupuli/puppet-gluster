# == Define: gluster::volume::option
#
# set or remove a Gluster volume option
#
# === Parameters
#
# $title: the name of the volume, a colon, and the name of the option
# $value: the value to set for this option
# $ensure: whether to set or remove an option
#
# === Examples
#
# gluster::volume::option { 'gv0:nfs.disable':
#   value  => 'on',
# }
#
# gluster::volume::option { 'gv0:server.allow-insecure':
#   value  => 'on',
# }
#
#
# To remove a previously-set option:
# gluster::volume::option { 'gv0:feature.read-only':
#   ensure => absent,
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
define gluster::volume::option (
  $value  = undef,
  $ensure = true,
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
