# modules/ssh/manifests/init.pp - manage ssh stuff
# Copyright (C) 2007 admin@immerda.ch
#

#modules_dir { "sshd": }

class sshd {
    case $operatingsystem {
        gentoo: { include sshd::gentoo }
        redhat: { include sshd::redhat }
        centos: { include sshd::centos }
        openbsd: { include sshd::openbsd }
        default: { include sshd::default }
    }
}


class sshd::base {
	$real_sshd_config_source = $sshd_config_source ? {
	    '' => "sshd/sshd_config/${operatingsystem}_normal.erb",
    	default => $source,
	}

    $real_sshd_allowed_users = $sshd_allowed_users ? {
        ''  => 'root',
    	default => $sshd_allowed_users,
    }

    file { 'sshd_config':
        path => '/etc/ssh/sshd_config',
        owner => root,
        group => 0,
        mode => 600,
        content => template("${real_sshd_config_source}"),
    }
}

class sshd::linux inherits sshd::base {
    package{openssh:
	    ensure => present,
	}
    include sshd::service
    File[sshd_config]{
        notify => Service[sshd],
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
}
class sshd::ubuntu inherits sshd::debian {}

class sshd::redhat inherits sshd::linux {
    Package[openssh]{
        name => 'openssh-server',
    }
}
class sshd::centos inherits sshd::redhat {}

class sshd::openbsd inherits sshd::base {
    exec{sshd_refresh:
        command => "/bin/kill -HUP `/bin/cat /var/run/sshd.pid`",
	    refreshonly => true,
    }
    File[sshd_config]{
        notify => Exec[sshd_refresh],
    }
}

### service stuff 
class sshd::service {
    case $operatingsystem {
        debian: { include sshd::service::debian }
        ubuntu: { include sshd::service::ubuntu }
        default: { include sshd::service::base }
    }

class sshd::service::base {
    service{'sshd':
        name => 'sshd',
        enable => true,
        ensure => running,
		require => Package[openssh],
     }
}

class sshd::service::debian inherits sshd::service::base {
    Service[sshd]{
        name => 'ssh',
    }
}
class sshd::service::ubuntu inherits sshd::service::debian {}

### defines 
define sshd::deploy_auth_key(
        $source = '', 
        $user = 'root', 
        $target_dir = '/root/.ssh/', 
        $group = '' ) {

        $real_target = $target_dir ? {
                '' => "/home/$user/.ssh/",
                default => $target_dir,
        }

        $real_group = $group ? {
                '' => 0,
                default => $group,
        }

        $real_source = $source ? {
            '' => [ "puppet://$server/files/sshd/authorized_keys/${name}",
                    "puppet://$server/sshd/authorized_keys/${name}" ]
            default => "puppet://$server/$source",
        }

        file {$real_target:
                ensure => directory,
                owner => $user,
                group => $real_group,
                mode => 700,
        }

        file {"authorized_keys_${user}":
                path => "$real_target/authorized_keys",
                owner => $user,
                group => $real_group,
                mode => 600,
                source => $real_source,
        }
}
