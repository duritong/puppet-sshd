# manifests/client.pp

class sshd::client(
  $shared_ip = hiera('sshd_shared_ip','no'),
  $ensure_version = hiera('sshd_ensure_version','installed')
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

  if hiera('use_shorewall',false) {
    include shorewall::rules::out::ssh
  }
}
