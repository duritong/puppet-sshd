class sshd::debian inherits sshd::linux {

  # the templates for Debian need lsbdistcodename
  include assert_lsbdistcodename

    Package[openssh]{
        name => 'openssh-server',
    }
    Service[sshd]{
        name => 'ssh',
        hasstatus => false,
    }
}
