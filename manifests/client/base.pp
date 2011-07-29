class sshd::client::base {
  # this is needed because the gid might have changed
  config_file { '/etc/ssh/ssh_known_hosts':
  }

  # Now collect all server keys
  case $sshd_shared_ip {
    no:  { Sshkey <<||>> }
    yes: { Sshkey <<| tag == "fqdn" |>> }
  }
}
