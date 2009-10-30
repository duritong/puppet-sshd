class sshd::debian inherits sshd::linux {

  # the templates for Debian need lsbdistcodename
  include lsb
  File['sshd_config']{
    require => Package['lsb']
  }

  Package[openssh]{
    name => 'openssh-server',
  }
  Service[sshd]{
    name => 'ssh',
    hasstatus => false,
  }
}
