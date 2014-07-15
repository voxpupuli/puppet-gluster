define gluster::volume::option (
  $volume = undef,
  $value   = undef,
  $remove  = false,
) {

  if $remove {
    $cmd = "reset ${volume} ${title}"
  } else {
    $cmd = "set ${volume} ${title} ${value}"
  }

  exec { "gluster option ${title} ${value}":
    command => "${::gluster_binary} volume ${cmd}",
  }
}
