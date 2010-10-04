class sshd::client::base {
  # this is needed because the gid might have changed
  config_file { '/etc/ssh/ssh_known_hosts':
  }

  # Now collect all server keys
  Sshkey <<||>>
}
