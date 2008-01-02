# modules/ssh/manifests/init.pp - manage ssh stuff
# Copyright (C) 2007 admin@immerda.ch
#

modules_dir { "sshd": }

class sshd {

	case $operatingsystem {
		OpenBSD: {
			service{'sshd':
        			enable => true,
	                	ensure => running,
        		}
		}
		default: {
			service{'sshd':
                                enable => true,
                                ensure => running,
				require => Package[openssh],
                        }
			
			package{openssh:
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
		notify => Service[sshd],
        }
}
