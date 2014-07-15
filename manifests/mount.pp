define gluster::mount (
  $volume         = undef,
  $log_level      = undef,
  $log_file       = undef,
  $transport      = undef,
  $direct_io_mode = undef,
  $readdirp       = undef,
  $atboot         = yes,
  $dump           = 0,
  $pass           = 0,
  $ensure         = mounted, # defined, present, unmounted, absent, mounted.
) {

  if ! $volume or empty($volume) {
    fail('Volume parameter is mandatory for gluster::mount')
  }

  if $log_level {
    validate_string($log_level)
    $ll = $log_level
  }

  if $log_file {
    validate_string($log_file)
    $lf = $log_file
  }

  if $transport {
    validate_string($transport)
    $t = $transport
  }

  if $direct_io_mode {
    validate_string($direct_io_mode)
    $dim = $direct_io_mode
  }

  if $readdirp {
    validate_bool(str2bool($readdirp))
    $r = $readdirp
  }

  if ! member(['defined', 'present', 'unmounted', 'absent', 'mounted'], $ensure) {
    fail("Unknown option ${ensure} for ensure")
  }

  $mount_options = [ "_netdev", "${ll}", "${lf}", "${t}", "${dim}", "${r}", ]
  $options = join(delete($mount_options, ''), ' ')

  mount { $title:
    ensure  => $ensure,
    atboot  => $atboot,
    device  => $volume,
    fstype  => 'glusterfs',
    dump    => $dump,
    pass    => $pass,
    options => $options,
  }
}
