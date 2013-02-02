class sshd::base {

  $sshd_config_content = $::lsbdistcodename ? {
    ''      => template("sshd/sshd_config/${::operatingsystem}.erb"),
    default => template ("sshd/sshd_config/${::operatingsystem}_${::lsbdistcodename}.erb"),
  }

  file { 'sshd_config':
    path    => '/etc/ssh/sshd_config',
    content => $sshd_config_content,
    notify  => Service[sshd],
    owner   => root,
    group   => 0,
    mode    => '0600';
  }

  # Now add the key, if we've got one
  case $::sshrsakey {
    '': { info("no sshrsakey on ${::fqdn}") }
    default: {
      @@sshkey{$::fqdn:
        ensure => present,
        tag    => 'fqdn',
        type   => ssh-rsa,
        key    => $::sshrsakey,
      }
      # In case the node has uses a shared network address,
      # we don't define a sshkey resource using an IP address
      if $sshd::shared_ip == 'no' {
        @@sshkey{$::ipaddress:
          ensure => present,
          tag    => 'ipaddress',
          type   => ssh-rsa,
          key    => $::sshrsakey,
        }
      }
    }
  }
  service{'sshd':
    ensure    => running,
    name      => 'sshd',
    enable    => true,
    hasstatus => true,
    require   => File[sshd_config],
  }
}
