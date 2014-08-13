# == Define: gluster::volume::option
#
# set or remove a Gluster volume option
#
# === Parameters
#
# $title: the name of the option to (re)set
# $volume: the name of the Gluster volume on which to operate
# $value: the value to set for this option
# $remove: whether to remove a previously-set option
#
# === Examples
#
# gluster::volume::option { 'nfs.disable':
#   volume => 'gv0',
#   value  => 'on',
# }
#
# gluster::volume::option { 'server.allow-insecure':
#   volume => 'gv0',
#   value  => 'on',
# }
#
# gluster::volume::option { 'feature.read-only':
#   volume => 'gv0',
#   remove => true,
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
  $volume = undef,
  $value   = undef,
  $remove  = false,
) {

  if ! $volume {
    fail('Volume is a mandatory parameter to gluster::volume::option!')
  }

  if $remove {
    $cmd = "reset ${volume} ${title}"
  } else {
    $cmd = "set ${volume} ${title} ${value}"
  }

  exec { "gluster option ${title} ${value}":
    command => "${::gluster_binary} volume ${cmd}",
  }
}
