# wrapper to have some defaults.
define sshd::ssh_authorized_key(
    $ensure = 'present',
    $type = 'ssh-dss',
    $key = 'absent',
    $user = '',
    $target = undef,
    $options = 'absent'
){

  if ($ensure=='present') and ($key=='absent') {
    fail("You have to set \$key for Sshd::Ssh_authorized_key[${name}]!")
  }

  $real_user = $user ? {
    false   => $name,
    ''      => $name,
    default => $user,
  }

  case $target {
    undef,'': {
      case $real_user {
        'root': { $real_target = '/root/.ssh/authorized_keys' }
        default: { $real_target = "/home/${real_user}/.ssh/authorized_keys" }
      }
    }
    default: {
      $real_target = $target
    }
  }
  ssh_authorized_key{$name:
    ensure => $ensure,
    type   => $type,
    key    => $key,
    user   => $real_user,
    target => $real_target,
  }

  case $options {
    'absent': { info("not setting any option for ssh_authorized_key: ${name}") }
    default: {
      Ssh_authorized_key[$name]{
        options => $options,
      }
    }
  }
}
