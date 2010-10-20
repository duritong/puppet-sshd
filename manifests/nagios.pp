define sshd::nagios {
  nagios::service{ "ssh_port_${name}": check_command => "check_ssh_port!$name" }
}
