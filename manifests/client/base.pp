class sshd::client::base {
  # this is needed because the gid might have changed
  file { '/etc/ssh/ssh_known_hosts':
    ensure => present,
    mode   => '0644',
    owner  => root,
    group  => 0;
  }

  # Now collect all server keys
  case $sshd::client::shared_ip {
    no:  { Sshkey <<||>> }
    yes: { Sshkey <<| tag == fqdn |>> }
  }

  if $sshd::client::hardened {
    file {
      '/etc/ssh/ssh_config':
        ensure  => present,
        source  => ["puppet:///modules/site_sshd/${::fqdn}/hardened_ssh_config",
                    "puppet:///modules/site_sshd/hardened_ssh_config",
                    "puppet:///modules/sshd/ssh_config/hardened/${::operatingsystem}_${::operatingsystemmajrelease}",
                    "puppet:///modules/sshd/ssh_config/hardened/${::operatingsystem}_${::lsbdistcodename}",
                    "puppet:///modules/sshd/ssh_config/hardened/${::operatingsystem}"],
        notify  => Service[sshd],
        owner   => root,
        group   => 0,
        mode    => '0644';
    }
  }
}
