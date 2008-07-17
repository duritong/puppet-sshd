# manifests/client.pp

class sshd::client {
    case $operatingsystem {
        debian: { include sshd::client::debian }
        default: { include sshd::client::base }
    }
}

class sshd::client::base {
    package {'openssh-clients':
        ensure => installed,
    }

    # this is needed because the gid might have changed
    file { '/etc/ssh/ssh_known_hosts':
            mode => 0644, owner => root, group => 0;
    }
    
    # Now collect all server keys
    Sshkey <<||>>
}

class sshd::client::debian inherits sshd::client::base {
    Package['openssh-clients']{
        name => 'openssh-client',
    }
}
