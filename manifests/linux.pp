class sshd::linux inherits sshd::base {
    package{openssh:
      ensure => present,
  }
    File[sshd_config]{
        require +> Package[openssh],
    }
}
