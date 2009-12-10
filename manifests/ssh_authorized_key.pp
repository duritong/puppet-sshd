# wrapper to have some defaults.
define sshd::ssh_authorized_key(
    $type = 'ssh-dss',
    $key,
    $user = 'root',
    $target = undef,
    $options = 'absent'
){

  $real_user = $user ? {
    false => $name,
    "" => $name,
    default => $user,
  }

  case $target {
    undef: {
      case $user {
        'root': { $real_target = '/root/.ssh/authorized_keys' }
        default: { $real_target = "/home/${user}/.ssh/authorized_keys" }
      }
    }
    default: {
      $real_target = $target
    }
  }
  ssh_authorized_key{$name:
    type => $type,
    key => $key,
    user => $real_user,
    target => $real_target,
  }

  case $options {
    'absent': { info("not setting any option for ssh_authorized_key: $name") }
    default: {
      Ssh_authorized_key[$name]{
        options => $options,
      }
    }
  }
}
