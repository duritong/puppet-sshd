class sshd::debian inherits sshd::linux {

  # the templates for Debian need lsbdistcodename
  require lsb

  Package[openssh]{
    name => 'openssh-server',
  }

  $sshd_restartandstatus = $::lsbdistcodename ? {
    etch    => false,
    default => true
  }

  Service[sshd]{
    name       => 'ssh',
    pattern    => 'sshd',
    hasstatus  => $sshd_restartandstatus,
    hasrestart => $sshd_restartandstatus,
  }
}
