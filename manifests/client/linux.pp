class sshd::client::linux inherits sshd::client::base {
  if $ssh_ensure_version == '' { $ssh_ensure_version = 'installed' }
  package {'openssh-clients':
    ensure => $ssh_ensure_version,
  }
}
