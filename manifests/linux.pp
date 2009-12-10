class sshd::linux inherits sshd::base {
  package{openssh:
    ensure => $sshd_ensure_version,
  }
  File[sshd_config]{
    require +> Package[openssh],
  }
}
