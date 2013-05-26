class sshd(
  $manage_nagios = false,
  $nagios_check_ssh_hostname = 'absent',
  $ports = [ 22 ],
  $shared_ip = 'no',
  $ensure_version = 'installed',
  $listen_address = [ '0.0.0.0', '::' ],
  $allowed_users = '',
  $allowed_groups = '',
  $use_pam = 'no',
  $permit_root_login = 'without-password',
  $password_authentication = 'no',
  $kerberos_authentication = 'no',
  $kerberos_orlocalpasswd = 'yes',
  $kerberos_ticketcleanup = 'yes',
  $gssapi_authentication = 'no',
  $gssapi_cleanupcredentials = 'yes',
  $tcp_forwarding = 'no',
  $x11_forwarding = 'no',
  $agent_forwarding = 'no',
  $challenge_response_authentication = 'no',
  $pubkey_authentication = 'yes',
  $rsa_authentication = 'no',
  $strict_modes = 'yes',
  $ignore_rhosts = 'yes',
  $rhosts_rsa_authentication = 'no',
  $hostbased_authentication = 'no',
  $permit_empty_passwords = 'no',
  $authorized_keys_file = '%h/.ssh/authorized_keys',
  $hardened_ssl = 'no',
  $sftp_subsystem = '',
  $head_additional_options = '',
  $tail_additional_options = '',
  $print_motd = 'yes',
  $manage_shorewall = false,
  $shorewall_source = 'net'
) {

  class{'sshd::client':
    shared_ip        => $sshd::shared_ip,
    ensure_version   => $sshd::ensure_version,
    manage_shorewall => $manage_shorewall,
  }

  case $::operatingsystem {
    gentoo: { include sshd::gentoo }
    redhat,centos: { include sshd::redhat }
    openbsd: { include sshd::openbsd }
    debian,ubuntu: { include sshd::debian }
    default: { include sshd::base }
  }

  if $manage_nagios {
    sshd::nagios{$ports:
      check_hostname => $nagios_check_ssh_hostname
    }
  }

  if $manage_shorewall {
    class{'shorewall::rules::ssh':
      ports  => $ports,
      source => $shorewall_source
    }
  }
}
