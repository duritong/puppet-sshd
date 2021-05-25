class sshd::redhat inherits sshd::linux {
  Package[openssh] {
    name => 'openssh-server',
  }
  # make sure network is here when starting sshd
  if $sshd::listen_address != ['0.0.0.0', '::'] and versioncmp($facts['os']['release']['major'],'8') >= 0 {
    systemd::dropin_file {
      'sshd-wait-on-network':
        unit     => 'sshd.service',
        filename => 'wait-on-network.conf',
        content  => "[Unit]\nWants=network-online.target\nAfter=network-online.target",
        notify   => Service['sshd'],
    }
  }
}
