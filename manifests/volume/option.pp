# @summary set or remove a Gluster volume option
#
# @param title
#    the name of the volume, a colon, and the name of the option
# @param value
#    the value to set for this option. Boolean values will be coerced to
#    'on'/'off'.
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
) {

  $arr = $title.split(':')
  # do we have more than one array element?
  if count($arr) != 2 {
    fail("${title} does not parse as volume:option")
  }
  [$vol, $opt] = $arr

  $_value = $value ? {
    Boolean => gluster::onoff($value),
    default => String($value),
  }

  $cmd = if $ensure == 'absent' {
    "reset ${vol} ${opt}"
  } else {
    "set ${vol} ${opt} ${_value}"
  }

  exec { "gluster option ${vol} ${opt} ${_value}":
    path    => '/usr/bin:/usr/sbin:/bin',
    command => "${facts['gluster_binary']} volume ${cmd}",
    unless  => unless $ensure == 'absent' {
      gluster::cmd_volume_get_option($vol, $opt, $_value)
    },
  }
}
