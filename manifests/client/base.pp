class sshd::client::base {
    # this is needed because the gid might have changed
    file { '/etc/ssh/ssh_known_hosts':
            mode => 0644, owner => root, group => 0;
    }

    # Now collect all server keys
    Sshkey <<||>>
}
