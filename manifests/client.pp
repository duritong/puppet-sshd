# manifests/client.pp

class sshd::client {
    case $operatingsystem {
        debian: { include sshd::client::debian }
        default: { 
            case $kernel {
                linux: { include sshd::client::linux }
                default:  { include sshd::client::base }
            }
        }
    }
}

class sshd::client::base {

  case $sshd_ensure_version {
    '': { $sshd_ensure_version = "present" }
  }
  
  package{openssh-clients:
    ensure => $sshd_ensure_version,
  }

  # this is needed because the gid might have changed
  file { '/etc/ssh/ssh_known_hosts':
    mode => 0644, owner => root, group => 0;
  }
  
  # Now collect all server keys
  Sshkey <<||>>
}

class sshd::client::linux inherits sshd::client::base {
}

class sshd::client::debian inherits sshd::client::linux {
    Package['openssh-clients']{
        name => 'openssh-client',
    }
}
