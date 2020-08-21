# @summary Mounts a Gluster volume
#
# @param volume
#    the volume to mount, in "server:/volname" format
# @param log_level
#    the GlusterFS log level to use
# @param log_file
#    the file to which to log this volume
# @param transport
#    TCP or RDMA
# @param direct_io_mode
#    whether or not to use direct io mode
# @param readdirp
#    whether or not to use readdirp
# @param atboot
#    whether to add this volume to /etc/fstab
# @param options
#    a comma-separated list of GlusterFS mount options
# @param dump
#    enable or disable dump in /etc/fstab
# @param pass
#    the sequence value for fsck for this volume in /etc/fstab
# @param ensure
#    the state to ensure
#
# @example
#   gluster::mount { 'data1':
#     ensure    => present,
#     volume    => 'srv1.local:/data1',
#     transport => 'tcp',
#     atboot    => true,
#     dump      => 0,
#     pass      => 0,
#   }
#
# @author Scott Merrill <smerrill@covermymeds.com>
# @note Copyright 2014 CoverMyMeds, unless otherwise noted
#
define gluster::mount (
  String $volume,
  Variant[Enum['yes', 'no'], Boolean] $atboot                           = 'yes',
  String $options                                                       = 'defaults',
  Integer $dump                                                         = 0,
  Integer $pass                                                         = 0,
  Enum['defined', 'present', 'unmounted', 'absent', 'mounted'] $ensure  = 'mounted',
  Optional[String] $log_level                                           = undef,
  Optional[String] $log_file                                            = undef,
  Optional[String] $transport                                           = undef,
  Optional[String] $direct_io_mode                                      = undef,
  Optional[Boolean] $readdirp                                           = undef,
) {
  if $log_level {
    $ll = "log-level=${log_level}"
  } else {
    $ll = undef
  }

  if $log_file {
    $lf = "log-file=${log_file}"
  } else {
    $lf = undef
  }

  if $transport {
    $t = "transport=${transport}"
  } else {
    $t = undef
  }

  if $direct_io_mode {
    $dim = "direct-io-mode=${direct_io_mode}"
  } else {
    $dim = undef
  }

  if $readdirp {
    $r = "usereaddrip=${readdirp}"
  } else {
    $r = undef
  }

  $mount_options = [$options, $ll, $lf, $t, $dim, $r,]
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
