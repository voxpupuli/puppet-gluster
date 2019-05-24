# Create a command string to get option `$opt` from gluster volume `$vol`, and
# optionally compare it against `$comparison`.
#
# @param vol [Gluster::VolumeName] Gluster volume name
# @param opt [Gluster::OptionName] Gluster volume option name
# @param comparison [Optional[String]] Optional string to compare the existing
#   value against
# @return [String]
#
# @example Usage
#
#   ```puppet
#   gluster::cmd_volume_get_option('data', 'nfs.disable', String(true))
#   ```
#
function gluster::cmd_volume_get_option(
  Gluster::VolumeName   $vol,
  Gluster::VolumeOption $opt,
  Optional[Any]         $comparison = undef,
) {
  $_cmd = "${::gluster_binary} volume get ${vol} ${opt}"

  unless $comparison {
    return $_cmd
  }

  $_comparison = $comparison ? {
    Undef   => '\(null\)',
    Boolean => gluster::onoff($comparison),
    default => $comparison,
  }

  "${_cmd} | tail -n1 | grep -E '^${opt} +${_comparison} *\$'"
}
