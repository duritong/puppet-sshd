class sshd::client::base {
  # this is needed because the gid might have changed
  file { '/etc/ssh/ssh_known_hosts':
    owner => root, group => 0, mode => 0644;
  }

  # Now collect all server keys
  case $sshd_internal_ip {
    no:  { Sshkey <<||>> }
    yes: { Sshkey <<| tag == "fqdn" |>> }
  }
}
