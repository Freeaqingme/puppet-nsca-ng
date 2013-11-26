
define nsca_ng::client::exported (
  $identity,
  $password,
  $commands = '.*',
  $services = '',
  $hosts    = '',
  $auth_template = 'nsca_ng/authorization.cfg.erb'
) {

  file { "/etc/nsca-ng.d/${identity}.cfg":
    owner    => $icinga::config_file_owner,
    group    => $icinga::config_file_group,
    mode     => 0600,
    content  => template($auth_template),
    notify   => Service[ 'nsca-ng-server' ]
  }
}
