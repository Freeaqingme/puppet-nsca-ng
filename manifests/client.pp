class nsca_ng::client (
  $version = 1.2,
) {

  exec { 'ncsa-ng_download-pkg':
    command => "wget http://www.nsca-ng.org/download/debian/nsca-ng-client_${version}_${::archictecture}.deb",
    cwd     => '/var/lib/puppet',
    creates => "/var/lib/puppet/nsca-ng-client_${version}_${::archictecture}.deb",
  }

  package { 'nsca-ng-client':
    ensure   => latest,
    provider => dpkg,
    source   => "/var/lib/puppet/nsca-ng-client_${version}_${::archictecture}.deb",
    require  => Exec['ncsa-ng_download-pkg']
  }

}
