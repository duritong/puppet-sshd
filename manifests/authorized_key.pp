# wrapper to have some defaults.
define sshd::authorized_key(
  $ensure  = 'present',
  $type    = 'ssh-rsa',
  $key     = 'absent',
  $user    = $name,
  $target  = undef,
  $options = false,
  $override_builtin = undef
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

  # The ssh_authorized_key built-in function (in 4.8.2 at least) will not write
  # an authorized_keys file for a mortal user to a directory they don't have
  # write permission to, puppet attempts to create the file as the user
  # specified with the user parameter and fails.  Since ssh will refuse to use
  # authorized_keys files not owned by the user, or in files/directories that
  # allow other users to write, this behavior is deliberate in order to prevent
  # typical non-working configurations. However, it also prevents the case of
  # puppet, running as root, writing a file owned by a mortal user to a common
  # authorized_keys directory such as one might specify in sshd_config with
  # something like 'AuthorizedKeysFile /etc/ssh/authorized_keys/%u' So we
  # provide a way to override the built-in and instead just install via a file
  # resource. There is no additional security risk here, it's nothing a user
  # can't already do by writing their own file resources, we still depend on the
  # filesystem permissions to keep things safe.
  if $override_builtin {
    $header = "# HEADER: This file is managed by Puppet.\n"

    if $options == 'absent' {
      info("not setting any option for ssh_authorized_key: ${name}")
      $content = "${header}${type} ${key}\n"
    } else {
      $content = "${header}${options} ${type} ${key}\n"
    }

    file { $real_target:
      ensure  => $ensure,
      content => $content,
      owner   => $user,
      mode    => '0600',
    }

  } else {
    ssh_authorized_key { $name:
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
}
