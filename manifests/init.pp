#
# ssh module
#
# Copyright 2008, admin(at)immerda.ch
# Copyright 2008, Puzzle ITC GmbH
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# This program is free software; you can redistribute 
# it and/or modify it under the terms of the GNU 
# General Public License version 3 as published by 
# the Free Software Foundation.
#
# Deploy authorized_keys file with the define
#     sshd::deploy_auth_key
# 
# shdd-config:
#
# The configuration of the sshd is rather strict and
# might not fit all needs. However there are a bunch 
# of variables, which you might consider to configure. 
# Checkout the following:
#
# sshd_allowed_users:           list of usernames separated by spaces. 
#                               set this for example to "foobar root"
#                               to ensure that only user foobar and root
#                               might login. 
#                               Default: empty -> no restriction is set
# 
# sshd_use_pam:                 if you want to use pam or not for authenticaton
#                               Values: no or yes. 
#                               Default: no
#
# sshd_permit_root_login:       If you want to allow root logins or not.
#                               Valid values: yes, no, without-password, forced-commands-only
#                               Default: without-password
#
# sshd_password_authentication: If you want to enable password authentication or not
#                               Valid values: yes or no
#                               Default: no
# 
# sshd_x11_forwarding:          If you want to enable x11 forwarding 
#                               Valid Values: yes or no
#                               Default: no
#

class sshd {
    case $operatingsystem {
        gentoo: { include sshd::gentoo }
        redhat: { include sshd::redhat }
        centos: { include sshd::centos }
        openbsd: { include sshd::openbsd }
        debian: { include sshd::debian }
        ubuntu: { include sshd::ubuntu }
        default: { include sshd::default }
    }
}


class sshd::base {
    # prepare variables to use in templates 
    $real_sshd_allowed_users = $sshd_allowed_users ? {
        ''  => '',
        default => $sshd_allowed_users
    }
    $real_sshd_use_pam = $sshd_use_pam ? {
        '' => 'no',
        default => $sshd_use_pam
    }
    $real_sshd_permit_root_login = $sshd_permit_root_login ? {
        '' => 'without-password',
        default => $sshd_permit_root_login
    }
    $real_sshd_password_authentication = $sshd_password_authentication ? {
        '' => 'no',
        default => $sshd_password_authentication
    }
    $real_sshd_x11_forwarding = $sshd_x11_forwarding ? {
        '' => 'no',
        default => $sshd_x11_forwarding
    }

    file { 'sshd_config':
        path => '/etc/ssh/sshd_config',
        owner => root,
        group => 0,
        mode => 600,
        content => template("sshd/sshd_config/${operatingsystem}_normal.erb"),
        notify => Service[sshd],
    }
    service{'sshd':
        name => 'sshd',
        enable => true,
        ensure => running,
        hasstatus => true,
		require => File[sshd_config],
     }
}

class sshd::linux inherits sshd::base {
    package{openssh:
	    ensure => present,
	}
    File[sshd_config]{
        require +> Package[openssh],
    }
}

class sshd::gentoo inherits sshd::linux {
    Package[openssh]{
        category => 'net-misc',
    }
}

class sshd::debian inherits sshd::linux {
    Package[openssh]{
        name => 'openssh-server',
    }
    Service[sshd]{
        name => 'ssh',
        hasstatus => false,
    }
}
class sshd::ubuntu inherits sshd::debian {}

class sshd::redhat inherits sshd::linux {
    Package[openssh]{
        name => 'openssh-server',
    }
}
class sshd::centos inherits sshd::redhat {}

class sshd::openbsd inherits sshd::base {
    Service[sshd]{
        restart => '/bin/kill -HUP `/bin/cat /var/run/sshd.pid`',
	    stop => '/bin/kill `/bin/cat /var/run/sshd.pid`',
        start => '/usr/sbin/sshd',
        hasstatus => false,
    }
}

### defines 
define sshd::deploy_auth_key(
        $source = 'present',
        $user = 'root', 
        $target_dir = '/root/.ssh/', 
        $group = 0 ) {

        $real_target = $target_dir ? {
                '' => "/home/$user/.ssh/",
                default => $target_dir,
        }

        file {$real_target:
                ensure => directory,
                owner => $user,
                group => $group,
                mode => 700,
        }

        case $source {
            'present': { $keysource = $name }
            default: { $keysource = $source }
        }

        file {"authorized_keys_${user}":
                path => "$real_target/authorized_keys",
                owner => $user,
                group => $group,
                mode => 600,
                source => [ "puppet://$server/files/sshd/authorized_keys/${keysource}",
                    "puppet://$server/files/sshd/authorized_keys/${fqdn}",
                    "puppet://$server/files/sshd/authorized_keys/default",
                    "puppet://$server/sshd/authorized_keys/${name}",
                    "puppet://$server/sshd/authorized_keys/${fqdn}",
                    "puppet://$server/sshd/authorized_keys/default" ],
        }
}
