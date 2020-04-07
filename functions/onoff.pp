function gluster::onoff (
  Boolean $value,
) {
  if $value {
    'on'
  } else {
    'off'
  }
}
