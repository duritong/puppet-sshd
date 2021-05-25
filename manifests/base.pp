# The base class to setup the common things.
# This is a private class and will always be used
# throught the sshd class itself.
class sshd::base {
  if $facts['os']['family'] == 'Debian' {
    $osrelease = $facts['os']['distro']['codename']
  } else {
    $osrelease = $facts['os']['release']['major']
  }

  if empty($osrelease) {
    $sshd_config_content = template("sshd/sshd_config/${facts['os']['name']}.erb")
  } else {
    $sshd_config_content = template("sshd/sshd_config/${facts['os']['name']}_${osrelease}.erb")
  }

  file {
    'sshd_config':
      path    => '/etc/ssh/sshd_config',
      content => $sshd_config_content,
      notify  => Service['sshd'],
      owner   => root,
      group   => 0,
      mode    => '0600';
  }
  if $sshd::harden_moduli {
    exec { 'harden_ssh_moduli':
      umask       => '077',
      environment => ['TMP=/etc/ssh/moduli_strong.$RANDOM'],
      command     => 'awk \'$5 >= 2048\' /etc/ssh/moduli > $TMP && \
        mv $TMP /etc/ssh/moduli',
      unless      => 'awk \'$5 < 2048 { exit 1 }\' /etc/ssh/moduli',
      notify      => Service['sshd'],
    }
  }

  # Now add the key, if we've got one
  if $settings::storeconfigs {
    if !empty($facts['ssh']['rsa']['key']) {
      @@sshkey { "${facts['networking']['fqdn']}-rsa":
        # workaround https://tickets.puppetlabs.com/browse/PUP-6589
        host_aliases => $facts['networking']['fqdn'],
        tag          => 'fqdn',
        type         => 'ssh-rsa',
        key          => $facts['ssh']['rsa']['key'],
      }
      # In case the node has uses a shared network address,
      # we don't define a sshkey resource using an IP address
      if !$sshd::shared_ip {
        @@sshkey { "${sshd::sshkey_ipaddress}-rsa":
          host_aliases => $sshd::sshkey_ipaddress,
          tag          => 'ipaddress',
          type         => 'ssh-rsa',
          key          => $facts['ssh']['rsa']['key'],
        }
        if $sshd::sshkey_ip6address and $sshd::sshkey_ip6address !~ /^fe80/ {
          @@sshkey { "${sshd::sshkey_ip6address}-rsa":
            host_aliases => $sshd::sshkey_ip6address,
            tag          => 'ipaddress',
            type         => 'ssh-rsa',
            key          => $facts['ssh']['rsa']['key'],
          }
        }
      }
    }
    if !empty($facts['ssh']['ed25519']['key']) {
      @@sshkey { "${facts['networking']['fqdn']}-ed25519":
        host_aliases => $facts['networking']['fqdn'],
        tag          => 'fqdn',
        type         => 'ssh-ed25519',
        key          => $facts['ssh']['ed25519']['key'],
      }
      # In case the node has uses a shared network address,
      # we don't define a sshkey resource using an IP address
      if !$sshd::shared_ip {
        @@sshkey { "${sshd::sshkey_ipaddress}-ed25519":
          host_aliases => $sshd::sshkey_ipaddress,
          tag          => 'ipaddress',
          type         => 'ssh-ed25519',
          key          => $facts['ssh']['ed25519']['key'],
        }
        if $sshd::sshkey_ip6address and $sshd::sshkey_ip6address !~ /^fe80/ {
          @@sshkey { "${sshd::sshkey_ip6address}-ed25519":
            host_aliases => $sshd::sshkey_ip6address,
            tag          => 'ipaddress',
            type         => 'ssh-ed25519',
            key          => $facts['ssh']['ed25519']['key'],
          }
        }
      }
    }
  } else {
    debug('storeconfigs is not set => not adding key')
  }

  if $sshd::purge_sshkeys {
    resources { 'sshkey':
      purge => true,
    }
  }
  service { 'sshd':
    ensure    => running,
    name      => 'sshd',
    enable    => true,
    hasstatus => true,
    require   => File['sshd_config'],
  }
}
