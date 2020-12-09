# manage an sshd installation
class sshd(
  Boolean
    $manage_nagios = false,
  $nagios_check_ssh_hostname = 'absent',
  Array[Variant[String,Integer]]
    $ports = [ 22 ],
  Boolean
    $shared_ip = false,
  $ensure_version = 'installed',
  Array[String]
    $listen_address = [ '0.0.0.0', '::' ],
  $allowed_users = '',
  $allowed_groups = '',
  $use_pam = 'no',
  $use_dns = 'no',
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
  $authorized_keys_file = $facts['osfamily'] ? {
    'Debian' => $facts['operatingsystemmajrelease'] ? {
      '6'     => '%h/.ssh/authorized_keys',
      default => '%h/.ssh/authorized_keys %h/.ssh/authorized_keys2',
    },
    'RedHat' => $facts['operatingsystemmajrelease'] ? {
      '5'     => '%h/.ssh/authorized_keys',
      '6'     => '%h/.ssh/authorized_keys',
      default => '%h/.ssh/authorized_keys',
    },
    'OpenBSD' => '%h/.ssh/authorized_keys',
    default   => '%h/.ssh/authorized_keys %h/.ssh/authorized_keys2',
  },
  Variant[Boolean,String]
    $hardened = false,
  Boolean
    $hardened_client = false,
  Boolean
    $harden_moduli = false,
  Boolean
    $use_host_dsa_key = true,
  Boolean
    $use_host_ecdsa_key = false,
  $sftp_subsystem = '',
  $head_additional_options = '',
  $tail_additional_options = '',
  $print_motd = 'yes',
  Array[String[1]]
    $accept_env = ['LANG', 'LC_*'],
  Boolean
    $manage_firewall = false,
  $firewall_source = 'net',
  Stdlib::IP::Address::V4::Nosubnet $sshkey_ipaddress = pick($facts['default_ipaddress'],$facts['ipaddress']),
  Optional[Stdlib::IP::Address::V6::Nosubnet] $sshkey_ip6address = $facts['networking']['ip6'],
  Boolean
    $manage_client = true,
  Boolean
    $purge_sshkeys = true,
) {

  if $manage_client {
    class{'sshd::client':
      shared_ip       => $shared_ip,
      ensure_version  => $ensure_version,
      manage_firewall => $manage_firewall,
      hardened        => $hardened_client,
    }
  }

  case $facts['operatingsystem'] {
    'Gentoo': { include sshd::gentoo }
    'RedHat','CentOS': { include sshd::redhat }
    'OpenBSD': { include sshd::openbsd }
    'Debian','Ubuntu': { include sshd::debian }
    default: { include sshd::base }
  }

  if $manage_nagios {
    $ports.each |$port| {
      sshd::nagios{String($port):
        check_hostname => $nagios_check_ssh_hostname,
      }
    }
  }

  if $manage_firewall {
    class{'firewall::rules::ssh':
      ports  => $ports,
      source => $firewall_source,
    }
  }
}
