#
# ssh module
#
# Copyright 2008, micah@riseup.net
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
#     sshd::ssh_authorized_key
# 
# sshd-config:
#
# The configuration of the sshd is rather strict and might not fit all
# needs. However there are a bunch of variables, which you might
# consider configuring.
#
# To set any of the following, simply set them as variables in your manifests
# before the class is included, for example:
#
# $sshd_listen_address = ['10.0.0.1 192.168.0.1']
# $sshd_use_pam = yes
# include sshd::debian
#
# The following is a list of the currently available variables:
#
# sshd_listen_address:          specify the addresses sshd should listen on
#                               set this to ['10.0.0.1 192.168.0.1'] to have it listen on both
#                               addresses, or leave it unset to listen on all
#                               Default: empty -> results in listening on 0.0.0.0
#
# sshd_allowed_users:           list of usernames separated by spaces. 
#                               set this for example to "foobar root"
#                               to ensure that only user foobar and root
#                               might login. 
#                               Default: empty -> no restriction is set
#
# sshd_allowed_groups           list of groups separated by spaces.
#                               set this for example to "wheel sftponly"
#                               to ensure that only users in the groups
#                               wheel and sftponly might login.
#                               Default: empty -> no restriction is set
#                               Note: This is set after sshd_allowed_users,
#                                     take care of the behaviour if you use
#                                     these 2 options together.
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
# sshd_challenge_response_authentication: If you want to enable ChallengeResponseAuthentication or not
# 				When disabled, s/key passowords are disabled
# 				Valid values: yes or no
#				Default: no
# 
# sshd_tcp_forwarding:		If you want to enable TcpForwarding
# 				Valid Values: yes or no
#				Default: no
#
# sshd_x11_forwarding:          If you want to enable x11 forwarding 
#                               Valid Values: yes or no
#                               Default: no
#
# sshd_agent_forwarding:	If you want to allow ssh-agent forwarding
# 				Valid Values: yes or no
#				Default: no
#
# sshd_pubkey_authentication:	If you want to enable public key authentication
# 				Valid Values: yes or no
#				Default: yes
#
# sshd_rsa_authentication:	If you want to enable RSA Authentication
# 				Valid Values: yes or no
#				Default: no
#				
# sshd_rhosts_rsa_authentication:	If you want to enable rhosts RSA Authentication
# 				Valid Values: yes or no
#				Default: no
#
# sshd_hostbased_authentication: If you want to enable HostbasedAuthentication
# 				 Valid Values: yes or no
#				 Default: no
#				
# sshd_strict_modes:		If you want to set StrictModes (check file modes/ownership before accepting login)
# 				Valid Values: yes or no
#				Default: yes
#
# sshd_permit_empty_passwords:	If you want enable PermitEmptyPasswords to allow empty passwords
# 				Valid Values: yes or no
#				Default: no
#
# sshd_port:                    If you want to specify a different port than the default 22
#                               Default: 22
#
# sshd_authorized_keys_file:    Set this to the location of the AuthorizedKeysFile (e.g. /etc/ssh/authorized_keys/%u)
#                               Default: AuthorizedKeysFile	%h/.ssh/authorized_keys
#
# sshd_sftp_subsystem:  Set a different sftp-subystem than the default one.
#                       Might be interesting for sftponly usage
#                       Default: empty -> no change of the default
#
# sshd_additional_options:  Set this to any additional sshd_options which aren't listed above.
#                           As well this option might be usefull to define complexer Match Blocks
#                           This string is going to be included, like it is defined. So take care!
#                           Default: empty -> not added.

class sshd {
    include sshd::client 

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
    case $sshd_listen_address {
      '': { $sshd_listen_address = [ '0.0.0.0', '::' ] }
    }
    case $sshd_allowed_users {
        '': { $sshd_allowed_users = '' }
    }
    case $sshd_allowed_groups {
      '': { $sshd_allowed_groups = '' }
    }
    case $sshd_use_pam {
        '': { $sshd_use_pam = 'no' }
    }
    case $sshd_permit_root_login {
        '': { $sshd_permit_root_login = 'without-password' }
    }
    case $sshd_password_authentication {
        '': { $sshd_password_authentication = 'no' }
    }
    case $sshd_tcp_forwarding {
    	'': { $sshd_tcp_forwarding = 'no' }
    }
    case $sshd_x11_forwarding {
        '': { $sshd_x11_forwarding = 'no' }
    }
    case $sshd_agent_forwarding {
    	'': { $sshd_agent_forwarding = 'no' }
    }
    case $sshd_challenge_response_authentication {
        '': { $sshd_challenge_response_authentication = 'no' }
    }
    case $sshd_pubkey_authentication {
    	'': { $sshd_pubkey_authentication = 'yes' }
    }
    case $sshd_rsa_authentication {
    	'': { $sshd_rsa_authentication = 'no' }
    }
    case $sshd_strict_modes {
    	'': { $sshd_strict_modes = 'yes' }
    }
    case $sshd_ignore_rhosts {
        '': { $sshd_ignore_rhosts = 'yes' }
    }
    case $sshd_rhosts_rsa_authentication {
    	'': { $sshd_rhosts_rsa_authentication = 'no' }
    }
    case $sshd_hostbased_authentication {
    	'': { $sshd_hostbased_authentication = 'no' }
    }
    case $sshd_permit_empty_passwords {
    	'': { $sshd_permit_empty_passwords = 'no' }
    }
    case $sshd_port {
      '': { $sshd_port = 22 }
    }
    case $sshd_authorized_keys_file {
      '': { $sshd_authorized_keys_file = "%h/.ssh/authorized_keys" }
    }
    case $sshd_sftp_subsystem {
        '': { $sshd_sftp_subsystem = '' }
    }
    case $sshd_additional_options {
        '': { $sshd_additional_options = '' }
    }
      
    file { 'sshd_config':
        path => '/etc/ssh/sshd_config',
        owner => root,
        group => 0,
        mode => 600,
        content => $lsbdistcodename ? {
          '' => template("sshd/sshd_config/${operatingsystem}.erb"),
          default => template ("sshd/sshd_config/${operatingsystem}_${lsbdistcodename}.erb"),
        },
        notify => Service[sshd],
    }
    # Now add the key, if we've got one
    case $sshrsakey_key {
        '': { info("no sshrsakey on $fqdn") }
        default: {
            @@sshkey{"$hostname.$domain":
                type => ssh-rsa,
                key => $sshrsakey_key,
                ensure => present,
            }
        }
    }
    service{'sshd':
        name => 'sshd',
        enable => true,
        ensure => running,
        hasstatus => true,
		require => File[sshd_config],
    }
    if $use_nagios {
        if $nagios_check_ssh {
            nagios::service{ "ssh_${fqdn}_port_${sshd_port}": check_command => "ssh_port!$sshd_port" }
        }
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

  # the templates for Debian need lsbdistcodename
  include assert_lsbdistcodename
  
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
# wrapper to have some defaults.
define sshd::ssh_authorized_key(
    $type = 'ssh-dss',
    $key,
    $user = 'root',
    $target = 'absent',
    $options = 'absent'
){
    ssh_authorized_key{$name:
        type => $type,
        key => $key,
        user => $user,
    }

    case $options {
        'absent': { info("not setting any option for ssh_authorized_key: $name") }
        default: {
            Ssh_authorized_key[$name]{
                options => $options,
            }
        }
    }
    case $target {
        'absent': { info("not setting any target for ssh_authorized_key: $name") }
        default: {
            Ssh_authorized_key[$name]{
                target => $target,
            }
        }
    }
}
