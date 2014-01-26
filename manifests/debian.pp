class sshd::debian inherits sshd::linux {

  # the templates for Debian need lsbdistcodename
  ensure_resource('package', 'lsb-release', {'ensure' => 'present' })
  #requires stdlib >= 3.2
  #ensure_packages(['lsb-release'])

  Package[openssh]{
    name => 'openssh-server',
  }

  Service[sshd]{
    name       => 'ssh',
    pattern    => 'sshd',
    hasstatus  => true,
    hasrestart => true,
  }
}
