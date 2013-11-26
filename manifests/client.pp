#
# [*server*]
#   String. The server (hostname) to connect to.
#
# [*identity*]
#   Optional. String. The string to identify with.
#   Defaults to $::fqdn
#
# [*password*]
#   Optional. String. The password to prove the given identity with.
#   If none is provided one will be generated.
#
# [*tls_ciphers*]
#   Optional. Array. The TLS ciphers to support. Consult the NSCA-NG
#   documentation to see which ones are supported.
#   Defaults to [ 'PSK-AES256-CBC-SHA' ]
#
# [*port*]
#   Optional. Numeric. The port the NSCA-NG server can be reached at.
#   Defaults to 5668
#
# [*timeout*]
#   Optional. Numeric.  Close the connection if the server didn't respond
#   for the specified number of seconds. If the timeout is set to 0,
#   send_nsca won't enforce connection timeouts.
#   Defaults to 15 (seconds)
#
# [*delay*]
#   Optional. Numeric. Wait for a random number of seconds between 0
#   and the specified delay before contacting the server.
#
# [*version*]
#   Optional. Float. The version to install (the default value of 1.2 may
#   be changed without notice!).
#
# [*template*]
#   Optional. String. The template to use for generating the client config file
#
# [*firewall*]
#   Optional. Bool. To configure the firewall, or not. That is the question.
#
# [*bin_file*]
#   Optional. String. The location of the binary for send_nsca. To support
#   multiple platforms this should be extracted to a ::params class where
#   a selection is made based on OS.
#
# [*config_file*]
#   Optional. String. The location of the configuration file for send_nsca.
#   To support multiple platforms this should be extracted to a ::params
#   class where a selection is made based on OS.
#
class nsca_ng::client (
  $server,
  $password    = 'foobar',
  $identity    = $::fqdn,
  $tls_ciphers = [ 'PSK-AES256-CBC-SHA' ],
  $port        = 5668,
  $timeout     = 15,
  $delay       = 0,
  $version     = 1.2,
  $template    = 'nsca_ng/client.cfg',
  $firewall    = params_lookup( 'firewall', 'global' ),
  $bin_file    = '/usr/sbin/send_nsca',
  $config_file = '/etc/send_nsca.cfg'
) {

  if $password == '' {
    fail('Autogeneration of password not yet supported')
  }

  if $firewall {
    firewall::rule { 'nsca-ng_download_pkg_fw':
      direction      => 'output',
      destination    => 'www.nsca-ng.org',
      destination_v6 => 'www.nsca-ng.org',
      port           => 80,
      protocol       => tcp
    }

    firewall::rule { "nsca-ng_tcp-${server}":
      direction       => 'output',
      port            => $port,
      protocol        => 'tcp',
      destination     => $server,
      destination_v6  => $server
    }
  }

  exec { 'nsca-ng_download-pkg':
    command => "wget http://www.nsca-ng.org/download/debian/nsca-ng-client_${version}~upstream1_${::architecture}.deb",
    cwd     => '/var/lib/puppet',
    creates => "/var/lib/puppet/nsca-ng-client_${version}~upstream1_${::architecture}.deb",
    before  => Package[ 'nsca-ng-client' ]
  }

  # For now, debian only
  package { 'nsca-ng-client':
    ensure   => latest,
    provider => dpkg,
    source   => "/var/lib/puppet/nsca-ng-client_${version}~upstream1_${::architecture}.deb",
    require  => Exec['nsca-ng_download-pkg']
  }

  file { "${nsca_ng::client::config_file}":
    content => template($::nsca_ng::client::template),
    mode    => 0644,
    owner   => root,
    group   => root,
    require => Package[ 'nsca-ng-client' ]
  }
}
