# manifests/client.pp

class sshd::client {
  include sshd::client::base
  case $operatingsystem {
    debian: { include sshd::client::debian }
    default: {
      case $kernel {
        linux: { include sshd::client::linux }
        default: { }
      }
    }
  }
  if $use_shorewall{
    include shorewall::rules::out::ssh
  }
}
