# wrapper to have some defaults.
define sshd::authorized_key(
    $ensure  = 'present',
    $type    = 'ssh-rsa',
    $key     = 'absent',
    $user    = $name,
    $target  = undef,
    $options = false,
){

  if ($ensure=='present') and ($key=='absent') {
    fail("You have to set \$key for Sshd::Authorized_key[${name}]!")
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
    ensure => $ensure,
    target => $real_target,
    user   => $user,
  }
  if $ensure == 'present' {
    Ssh_authorized_key[$name]{
      type => $type,
      key  => $key,
    }

    if $options {
      Ssh_authorized_key[$name]{
        options => $options,
      }
    }
  }
}
