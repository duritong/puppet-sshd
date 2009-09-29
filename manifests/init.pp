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
        redhat,centos: { include sshd::redhat }
        centos: { include sshd::centos }
        openbsd: { include sshd::openbsd }
        debian,ubuntu: { include sshd::debian }
        default: { include sshd::default }
    }

    if $use_nagios {
        if $nagios_check_ssh {
            nagios::service{ "ssh_${fqdn}_port_${sshd_port}": check_command => "ssh_port!$sshd_port" }
        }
    }

    if $use_shorewall{
      include shorewall::rules::ssh
    }
}
