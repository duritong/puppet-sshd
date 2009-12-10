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
  case $sshrsakey_key {
    '': { info("no sshrsakey on $fqdn") }
    default: {
      @@sshkey{"$hostname.$domain":
        type => ssh-rsa,
        key => $sshrsakey_key,
        ensure => present,
      }
      @@sshkey{"$ipaddress":
        type => ssh-rsa,
        key => $sshrsakey,
        ensure => present,
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
