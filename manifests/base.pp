class sshd::base {
    # prepare variables to use in templates
    case $sshd_listen_address {
      '': { $sshd_listen_address = [ '0.0.0.0', '::' ] }
    }
    case $sshd_allowed_users {
        '': { $sshd_allowed_users = '' }
    }
    case $sshd_allowed_groups {
      '': { $sshd_allowed_groups = '' }
    }
    case $sshd_use_pam {
        '': { $sshd_use_pam = 'no' }
    }
    case $sshd_permit_root_login {
        '': { $sshd_permit_root_login = 'without-password' }
    }
    case $sshd_password_authentication {
        '': { $sshd_password_authentication = 'no' }
    }
    case $sshd_tcp_forwarding {
    	'': { $sshd_tcp_forwarding = 'no' }
    }
    case $sshd_x11_forwarding {
        '': { $sshd_x11_forwarding = 'no' }
    }
    case $sshd_agent_forwarding {
    	'': { $sshd_agent_forwarding = 'no' }
    }
    case $sshd_challenge_response_authentication {
        '': { $sshd_challenge_response_authentication = 'no' }
    }
    case $sshd_pubkey_authentication {
    	'': { $sshd_pubkey_authentication = 'yes' }
    }
    case $sshd_rsa_authentication {
    	'': { $sshd_rsa_authentication = 'no' }
    }
    case $sshd_strict_modes {
    	'': { $sshd_strict_modes = 'yes' }
    }
    case $sshd_ignore_rhosts {
        '': { $sshd_ignore_rhosts = 'yes' }
    }
    case $sshd_rhosts_rsa_authentication {
    	'': { $sshd_rhosts_rsa_authentication = 'no' }
    }
    case $sshd_hostbased_authentication {
    	'': { $sshd_hostbased_authentication = 'no' }
    }
    case $sshd_permit_empty_passwords {
    	'': { $sshd_permit_empty_passwords = 'no' }
    }
    case $sshd_port {
      '': { $sshd_port = 22 }
    }
    case $sshd_authorized_keys_file {
      '': { $sshd_authorized_keys_file = "%h/.ssh/authorized_keys" }
    }
    case $sshd_sftp_subsystem {
        '': { $sshd_sftp_subsystem = '' }
    }
    case $sshd_additional_options {
        '': { $sshd_additional_options = '' }
    }
      
    file { 'sshd_config':
        path => '/etc/ssh/sshd_config',
        owner => root,
        group => 0,
        mode => 600,
        content => $lsbdistcodename ? {
          '' => template("sshd/sshd_config/${operatingsystem}.erb"),
          default => template ("sshd/sshd_config/${operatingsystem}_${lsbdistcodename}.erb"),
        },
        notify => Service[sshd],
    }
    # Now add the key, if we've got one
    case $sshrsakey_key {
        '': { info("no sshrsakey on $fqdn") }
        default: {
            @@sshkey{"$hostname.$domain":
                type => ssh-rsa,
                key => $sshrsakey_key,
                ensure => present,
            }
        }
    }
    service{'sshd':
        name => 'sshd',
        enable => true,
        ensure => running,
        hasstatus => true,
		    require => File[sshd_config],
    }
}
