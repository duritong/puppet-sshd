class sshd::client::base {
  # this is needed because the gid might have changed
  file { '/etc/ssh/ssh_known_hosts':
    ensure => present,
    mode   => '0644',
    owner  => root,
    group  => 0;
  }

  # Now collect all server keys
  if $settings::storeconfigs {
    if $sshd::client::shared_ip {
      Sshkey <<| tag == fqdn |>>
    } else {
      Sshkey <<||>>
    }
  } else {
    debug('storeconfigs is not set => skipping key collection')
  }


  if $sshd::client::hardened {
    if $osfamily == 'Debian' {
      $osrelease = $::lsbdistcodename
    } else {
      $osrelease = $operatingsystemmajrelease
    }
    file {
      '/etc/ssh/ssh_config':
        ensure => present,
        source => ["puppet:///modules/site_sshd/${::fqdn}/hardened_ssh_config",
                    'puppet:///modules/site_sshd/hardened_ssh_config',
                    "puppet:///modules/sshd/ssh_config/hardened/${::operatingsystem}_${osrelease}",
                    "puppet:///modules/sshd/ssh_config/hardened/${::operatingsystem}"],
        notify => Service[sshd],
        owner  => root,
        group  => 0,
        mode   => '0644';
    }
  }
}
