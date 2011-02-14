#
# ssh module
#
# Copyright 2008-2009, micah@riseup.net
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
# include sshd
#
# If you need to install a version of the ssh daemon or client package other than
# the default one that would be installed by 'ensure => installed', then you can
# set the following variables:
#
# $sshd_ensure_version = "1:5.2p2-6"
# $ssh_ensure_version = "1:5.2p2-6"
#
# To have nagios checks setup automatically for sshd services, simply
# set $use_nagios = true before the class is included. If you want to
# disable ssh nagios checking for a particular node (such as when ssh
# is firewalled), then you can set $nagios_check_ssh to false and that
# node will not be monitored.
# NOTE: this requires that you are using the nagios puppet module
# which supports the nagios native types via nagios::service 
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
# sshd_kerberos_authentication: If you want the password that is provided by the user to be
#                               validated through the Kerberos KDC. To use this option the
#                               server needs a Kerberos servtab which allows the verification of
#                               the KDC's identity.
#                               Valid values: yes or no
#                               Default: no
#
# sshd_kerberos_orlocalpasswd:  If password authentication through Kerberos fails, then the password
#                               will be validated via any additional local mechanism.
#                               Valid values: yes or no
#                               Default: yes
#
# sshd_kerberos_ticketcleanup:  Destroy the user's ticket cache file on logout?
#                               Valid values: yes or no
#                               Default: yes
#
# sshd_gssapi_authentication:   Authenticate users based on GSSAPI?
#                               Valid values: yes or no
#                               Default: no
#
# sshd_gssapi_cleanupcredentials: Destroy user's credential cache on logout?
#                                 Valid values: yes or no
#                                 Default: yes
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
# sshd_port:                    Deprecated, use sshd_ports instead.
#
# sshd_ports:                   If you want to specify a list of ports other than the default 22
#                               Default: [22]
#
#
# sshd_authorized_keys_file:    Set this to the location of the AuthorizedKeysFile (e.g. /etc/ssh/authorized_keys/%u)
#                               Default: AuthorizedKeysFile	%h/.ssh/authorized_keys
#
# sshd_sftp_subsystem:  Set a different sftp-subystem than the default one.
#                       Might be interesting for sftponly usage
#                       Default: empty -> no change of the default
#
# sshd_head_additional_options:  Set this to any additional sshd_options which aren't listed above.
#                                Anything set here will be added to the beginning of the sshd_config file.
#                                This option might be useful to define complicated Match Blocks
#                                This string is going to be included, like it is defined. So take care!
#                                Default: empty -> not added.
#
# sshd_tail_additional_options:  Set this to any additional sshd_options which aren't listed above.
#                                Anything set here will be added to the end of the sshd_config file.
#                                This option might be useful to define complicated Match Blocks
#                                This string is going to be included, like it is defined. So take care!
#                                Default: empty -> not added.

class sshd {
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
  case $sshd_kerberos_authentication {
    '': { $sshd_kerberos_authentication = 'no' }
  }
  case $sshd_kerberos_orlocalpasswd {
    '': { $sshd_kerberos_orlocalpasswd = 'yes' }
  }
  case $sshd_kerberos_ticketcleanup {
    '': { $sshd_kerberos_ticketcleanup = 'yes' }
  }
  case $sshd_gssapi_authentication {
    '': { $sshd_gssapi_authentication = 'no' }
  }
  case $sshd_gssapi_cleanupcredentials {
    '': { $sshd_gssapi_cleanupcredentials = 'yes' }
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
  if ( $sshd_port != '' ) and ( $sshd_ports != []) {
      err("Cannot use sshd_port and sshd_ports at the same time.")
  }
  if $sshd_port != '' {
      $sshd_ports = [ $sshd_port ]
  } elsif ! $sshd_ports {
      $sshd_ports = [ 22 ]
  }
  case $sshd_authorized_keys_file {
    '': { $sshd_authorized_keys_file = "%h/.ssh/authorized_keys" }
  }
  case $sshd_sftp_subsystem {
    '': { $sshd_sftp_subsystem = '' }
  }
  case $sshd_head_additional_options {
    '': { $sshd_head_additional_options = '' }
  }
  case $sshd_tail_additional_options {
    '': { $sshd_tail_additional_options = '' }
  }
  case $sshd_ensure_version {
    '': { $sshd_ensure_version = "present" }
  }

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
    case $nagios_check_ssh {
      false: { info("We don't do nagioschecks for ssh on ${fqdn}" ) }
      default: {
        sshd::nagios{$sshd_ports:
          check_hostname => $nagios_check_ssh_hostname ? {
            '' => 'absent',
            undef => 'absent',
            default => $nagios_check_ssh_hostname
          }
        }
      }
    }
  }

  if $use_shorewall{
    class{'shorewall::rules::ssh':
      ports => $sshd_ports,
    }
  }
}
