class sshd(
  $nagios_check_ssh = hiera('nagios_check_ssh',true),
  $nagios_check_ssh_hostname = hiera('nagios_check_ssh_hostname','absent'),
  $ports = hiera('sshd_ports',[ 22 ]),
  $shared_ip = hiera('sshd_shared_ip','no'),
  $ensure_version = hiera('sshd_ensure_version','installed'),
  $listen_address = hiera('sshd_listen_address',[ '0.0.0.0', '::' ]),
  $allowed_users = hiera('sshd_allowed_users',''),
  $allowed_groups = hiera('sshd_allowed_groups',''),
  $use_pam = hiera('sshd_use_pam','no'),
  $permit_root_login = hiera('sshd_permit_root_login','without-password'),
  $password_authentication = hiera('sshd_password_authentication','no'),
  $kerberos_authentication = hiera('sshd_kerberos_authentication','no'),
  $kerberos_orlocalpasswd = hiera('sshd_sshd_kerberos_orlocalpasswd','yes'),
  $kerberos_ticketcleanup = hiera('sshd_kerberos_ticketcleanup','yes'),
  $gssapi_authentication = hiera('sshd_gssapi_authentication','no'),
  $gssapi_cleanupcredentials = hiera('sshd_gssapi_cleanupcredentials','yes'),
  $tcp_forwarding = hiera('sshd_tcp_forwarding','no'),
  $x11_forwarding = hiera('sshd_x11_forwarding','no'),
  $agent_forwarding = hiera('sshd_agent_forwarding','no'),
  $challenge_response_authentication = hiera('sshd_challenge_response_authentication','no'),
  $pubkey_authentication = hiera('sshd_pubkey_authentication','yes'),
  $rsa_authentication = hiera('rsa_authentication','no'),
  $strict_modes = hiera('sshd_strict_modes','yes'),
  $ignore_rhosts = hiera('sshd_ignore_rhosts','yes'),
  $rhosts_rsa_authentication = hiera('sshd_rhosts_rsa_authentication','no'),
  $hostbased_authentication = hiera('sshd_hostbased_authentication','no'),
  $permit_empty_passwords = hiera('sshd_permit_empty_passwords','no'),
  $authorized_keys_file = hiera('sshd_authorized_keys_file','%h/.ssh/authorized_keys'),
  $hardened_ssl = hiera('sshd_hardened_ssl','no'),
  $sftp_subsystem = hiera('sshd_sftp_subsystem',''),
  $head_additional_options = hiera('sshd_head_additional_options',''),
  $tail_additional_options = hiera('sshd_tail_additional_options',''),
  $print_motd = hiera('sshd_print_motd','yes')
) {

  class{'sshd::client':
    shared_ip => $sshd::shared_ip,
    ensure_version => $sshd::ensure_version
  }

  case $::operatingsystem {
    gentoo: { include sshd::gentoo }
    redhat,centos: { include sshd::redhat }
    openbsd: { include sshd::openbsd }
    debian,ubuntu: { include sshd::debian }
    default: { include sshd::base }
  }

  if hiera('use_nagios',false) and $sshd::nagios_check_ssh {
    sshd::nagios{$sshd::ports:
      check_hostname => $sshd::nagios_check_ssh_hostname
    }
  }

  if hiera('use_shorewall', false) {
    class{'shorewall::rules::ssh':
      ports => $sshd::ports,
    }
  }
}
