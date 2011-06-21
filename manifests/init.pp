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
  case $sshd_hardened_ssl {
    '': { $sshd_hardened_ssl = 'no' }
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
    default: { include sshd::base }
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
