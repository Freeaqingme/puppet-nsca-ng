class nsca_ng::client (
  $version     = 1.2,
  $firewall    = params_lookup( 'firewall', 'global' ),
  $bin_file    = '/usr/sbin/send_nsca',
  $config_file = '/etc/send_nsca.cfg'
) {

  if $firewall {
    firewall::rule { 'nsca-ng_download_pkg_fw':
      direction      => 'output',
      destination    => 'www.nsca-ng.org',
      destination_v6 => 'www.nsca-ng.org',
      port           => 80,
      protocol       => tcp
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

}
