#
# == Class gluster::mount
#
# Mounts a Gluster volume
#
# === Parameters
#
# volume: the volume to mount, in "server:/volname" format
# log_level: the GlusterFS log level to use
# log_file: the file to which to log this volume
# transport: TCP or RDMA
# direct_io_mode: whether or not to use direct io mode
# readdirp: whether or not to use readdirp
# atboot: whether to add this volume to /etc/fstab
# options: a comma-separated list of GlusterFS mount options
# dump: enable or disable dump in /etc/fstab
# pass: the sequence value for fsck for this volume in /etc/fstab
# ensure: one of: defined, present, unmounted, absent, mounted
#
# === Examples
#
# gluster::mount { 'data1':
#   ensure    => present,
#   volume    => 'srv1.local:/data1',
#   transport => 'tcp',
#   atboot    => true,
#   dump      => 0,
#   pass      => 0,
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
define gluster::mount (
  String $volume,
  Optional[String] $log_level                                           = undef,
  Optional[String] $log_file                                            = undef,
  Optional[String] $transport                                           = undef,
  Optional[String] $direct_io_mode                                      = undef,
  Optional[Boolean] $readdirp                                           = undef,
  $atboot                                                               = yes,
  String $options                                                       = 'defaults',
  Integer $dump                                                         = 0,
  Integer $pass                                                         = 0,
  Enum['defined', 'present', 'unmounted', 'absent', 'mounted'] $ensure  = 'mounted',
) {

  if $log_level {
    $ll = "log-level=${log_level}"
  }

  if $log_file {
    $lf = "log-file=${log_file}"
  }

  if $transport {
    $t = "transport=${transport}"
  }

  if $direct_io_mode {
    $dim = "direct-io-mode=${direct_io_mode}"
  }

  if $readdirp {
    $r = "usereaddrip=${readdirp}"
  }

  $mount_options = [ $options, $ll, $lf, $t, $dim, $r, ]
  $_options = join(delete_undef_values($mount_options), ',')

  mount { $title:
    ensure   => $ensure,
    fstype   => 'glusterfs',
    remounts => false,
    atboot   => $atboot,
    device   => $volume,
    dump     => $dump,
    pass     => $pass,
    options  => $_options,
  }
}
