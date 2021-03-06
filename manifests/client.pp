# manages client configuration
class sshd::client(
  Boolean
    $shared_ip       = false,
  String
    $ensure_version  = 'installed',
  Boolean
    $manage_firewall = false,
  Boolean
    $hardened        = false,
) {
  case $::operatingsystem {
    debian,ubuntu: { include sshd::client::debian }
    default: {
      case $::kernel {
        linux: { include sshd::client::linux }
        default: { include sshd::client::base }
      }
    }
  }

  if $manage_firewall {
    include firewall::rules::out::ssh
  }
}
