class sshd::base {     
  file { 'sshd_config':
    path => '/etc/ssh/sshd_config',
    content => $lsbdistcodename ? {
      '' => template("sshd/sshd_config/${operatingsystem}.erb"),
      default => template ("sshd/sshd_config/${operatingsystem}_${lsbdistcodename}.erb"),
    },
    notify => Service[sshd],
    owner => root, group => 0, mode => 600;
  }

  # Now add the key, if we've got one
  case $sshrsakey {
    '': { info("no sshrsakey on $fqdn") }
    default: {
      @@sshkey{"$fqdn":
        tag    => "fqdn",
        type   => ssh-rsa,
        key    => $sshrsakey,
        ensure => present,
      }
      # In case the node has an internal network address,
      # we don't define a sshkey resource using an IP address
      if $sshd_internal_ip == "no" {
        @@sshkey{"$ipaddress":
          tag    => "ipaddress",
          type   => ssh-rsa,
          key    => $sshrsakey,
          ensure => present,
        }
      }
    }
  }
  service{'sshd':
    name => 'sshd',
    enable => true,
    ensure => running,
    hasstatus => true,
    require => File[sshd_config],
  }
}
