# manifests/client.pp

class sshd::client {
  case $operatingsystem {
    debian,ubuntu: { include sshd::client::debian }
    default: {
      case $kernel {
        linux: { include sshd::client::linux }
        default:  { include sshd::client::base }
      }
    }
  }
  if $use_shorewall{
    include shorewall::rules::out::ssh
  }
}
