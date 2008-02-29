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
                    debian => 'openssh-server',
                    ubuntu => 'openssh-server',
                    redhat => 'openssh-server',
                    centos => 'openssh-server',
                    default => 'openssh',
                },
                category => $operatingsystem ? {
	                gentoo => 'net-misc',
		        	default => '',
	            },
		        ensure => present,
			}

		}
	}

	$real_sshd_config_source = $sshd_config_source ? {
	    '' => "sshd/sshd_config/${operatingsystem}_normal.erb",
    	default => $source,
	}

    notice("sshd_allowed_users is set to ${sshd_allowed_users}")

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
    	notify => $operatingsystem ? { 
	        openbsd => Exec[sshd_refresh],
		    default => Service[sshd],
    	},
    }
}

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
            '' => [ "puppet://$server/sshd/authorized_keys/${name}",
                    "puppet://$server/dist/sshd/authorized_keys/${name}"],
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
