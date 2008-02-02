# modules/ssh/manifests/init.pp - manage ssh stuff
# Copyright (C) 2007 admin@immerda.ch
#

#modules_dir { "sshd": }

class sshd {

	case $operatingsystem {
		OpenBSD: {
			exec{sshd_refresh:
        	    command => "/bin/kill -HUP `/bin/cat /var/run/sshd.pid`",
	            refreshonly => true,
            }
		}
		default: {
			service{'sshd':
                name => $operatingsystem ? {
                    debian => 'ssh',
                    ubuntu => 'ssh',
                    default => 'sshd',
                },
                enable => true,
                ensure => running,
				require => Package[openssh],
            }
            
			package{openssh:
                name => $operatingsystem ? {
                    debian: => 'openssh-server',
                    ubuntu: => 'openssh-server',
                    redhat: => 'openssh-server',
                    centos: => 'openssh-server',
                    default: => 'openssh',
                },
                category => $operatingsystem ? {
	                gentoo => 'net-misc',
		        	default => '',
	            },
		        ensure => present,
			}

		}
	}
}

define sshd::sshd_config (
	$source = "",
	$allowed_users = 'root'
){
	$real_source = $source ? {
		'' => "${operatingsystem}_normal.erb",
		default => $source,
	}

	file { 'sshd_config':
        path => '/etc/ssh/sshd_config',
        owner => root,
        group => 0,
        mode => 600,
        content => template("sshd/sshd_config/${real_source}"),
		notify => $operatingsystem ? { 
			openbsd => Exec[sshd_refresh],
			default => Service[sshd],
		},
    }
}
