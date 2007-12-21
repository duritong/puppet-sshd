# modules/ssh/manifests/init.pp - manage ssh stuff
# Copyright (C) 2007 admin@immerda.ch
#

modules_dir { "sshd": }

class sshd {
        service{'sshd':
                enable => true,
                ensure => running,
                require => Package[openssh],
                subscribe => File[sshd_config]
        }

        package{ssh:
                name =>  $operatingsystem ? {
                        centos => openssh-server,
                        default => openssh,
                },
                alias   => 'openssh',
                category => $operatingsystem ? {
                        gentoo => 'net-misc',
                        default => '',
                },
                ensure => present,
        }
}

define sshd::sshd_config (
	$source = ""
){
	$real_source = $source ? {
		'' => "${operatingsystem}_normal",
		default => $source,
	}

	file { 'sshd_config':
                path => '/etc/ssh/sshd_config',
                owner => root,
                group => 0,
                mode => 600,
                source => $real_source,
		notify => Service[sshd],
        }
}
