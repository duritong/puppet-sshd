define sshd::nagios(
  $ensure = 'present',
  $check_hostname = 'absent'
) {
  case $check_hostname {
    'absent': {
      nagios::service{"ssh_port_${name}":
        ensure => $esnure,
        check_command => "check_ssh_port!$name"
      }
    }
    default: {
      nagios::service{"ssh_port_host_${name}_${check_hostname}":
        ensure => $esnure,
        check_command => "check_ssh_port_host!${name}!${check_hostname}"
      }
    }
  }
}
