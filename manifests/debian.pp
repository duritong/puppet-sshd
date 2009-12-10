class sshd::debian inherits sshd::linux {

  # the templates for Debian need lsbdistcodename
  include lsb
  File['sshd_config']{
    require +> Package['lsb']
  }

  Package[openssh]{
    name => 'openssh-server',
  }

  $sshd_restartandstatus = $lsbdistcodename ? {
    etch => false,
    lenny => true,
    default => false
  }

  Service[sshd]{
    name => 'ssh',
    pattern => 'sshd',
    hasstatus => $sshd_restartandstatus,
    hasrestart => $sshd_restartandstatus,
  }
}
