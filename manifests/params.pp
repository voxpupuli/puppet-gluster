class gluster::params {
  # parameters dealing with installation
  $install_server = true
  $install_client = true
  $version = 'LATEST'
  $repo    = true
  $repo_gpg_key_name = 'RPM-GPG-KEY-gluster.pub'
  $repo_gpg_key_path = '/etc/pki/rpm-gpg/'
  $repo_gpg_key_source = "puppet:///modules/${module_name}/${repo_gpg_key_name}"

  if ! $repo {
    # not using the upstream repo
    if $::osfamily == 'RedHat' {
      $vendor_server_package = $::operatingsystemmajrelease ? {
        # RHEL 6 and 7 provide Gluster packages natively
        /(6|7)/ => 'glusterfs',
        default => false
      }
      $vendor_client_package = $::operatingsystemmajrelease ? {
        /(6|7)/ => 'glusterfs-fuse',
        default => false,
      }
    }
    
    # we're not using the upstream repo, so we should have a vendor-defined
    # package at this point.  If we don't, we can't continue!
    if ! $vendor_server_package {
      fail("No vendor-supplied server package for ${::osfamily} version ${::operatingsystemmajrelease}")
    } else {
      $server_package = $vendor_server_package
    }
    if ! $vendor_client_package {
      fail("No vendor-supplied client package for ${::osfamily} version ${::operatingsystemmajrelease}")
    } else {
      $client_package = $vendor_client_package
    }
  } else {
    $server_package = 'glusterfs-server'
    $client_package = 'glusterfs-fuse'
  }

  # parameters dealing with a Gluster server instance
  $service_enable = true
  $pool = 'default'

  # parameters dealing with bricks

  # parameters dealing with volumes
}
