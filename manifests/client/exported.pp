
define nsca_ng::client::exported (
  $identity,
  $password,
  $services = '',
  $hosts    = '',
  $auth_template = 'nsca_ng/authorization.cfg.erb'
) {

  file { "/etc/nsca-ng.d/${identity}":
    owner    => $icinga::config_file_owner,
    group    => $icinga::config_file_group,
    mode     => 0600,
    content  => template($auth_template)
  }
}
