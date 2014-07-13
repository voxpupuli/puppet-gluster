define gluster::volume::option (
  $volume = undef,
  value = undef,
) {
  exec { "gluster option ${title} ${value}":
    command => "${::gluster_binary} volume set ${volume} ${title} ${value}",
  }
}
