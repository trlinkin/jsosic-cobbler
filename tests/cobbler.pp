#file { '/distro':
##    ensure  => 'directory',
#    owner   => 'root',
#    group   => 'root',
#    mode    => '0755',
#    recurse => 'false',
#}

include apache
include apache::mod::proxy
include apache::mod::proxy_http
include apache::mod::wsgi

class { 'cobbler':
  auth_module => 'authn_configfile',
}

include cobbler::web

cobbler::add_distro { 'CentOS-6.5-x86_64':
  arch       => 'x86_64',
  isolink    => 'http://mi.mirror.garr.it/mirrors/CentOS/6.5/isos/x86_64/CentOS-6.5-x86_64-bin-DVD1.iso',
  breed      => 'redhat',
  os_version => 'rhel6',
}

cobblerrepo { 'PuppetLabs-6-x86_64-deps':
  ensure         => present,
  arch           => 'x86_64',
  mirror         => 'http://yum.puppetlabs.com/el/6/dependencies/x86_64',
  mirror_locally => false,
  priority       => 99,
  require        => [ Service[$cobbler::service_name], Service[$cobbler::apache_service] ],
}

cobblerrepo { 'PuppetLabs-6-x86_64-products':
  ensure         => present,
  arch           => 'x86_64',
  mirror         => 'http://yum.puppetlabs.com/el/6/products/x86_64',
  mirror_locally => false,
  priority       => 99,
  require        => [ Service[$cobbler::service_name], Service[$cobbler::apache_service] ],
}

cobblerprofile { 'CentOS-6.5-x86_64':
  ensure      => present,
  distro      => 'CentOS-6.5-x86_64',
  nameservers => $cobbler::nameservers,
  repos       => ['PuppetLabs-6-x86_64-deps', 'PuppetLabs-6-x86_64-products' ],
  #kickstart   => '/somepath/kickstarts/CentOS-6.5-x86_64-static.ks',
}

cobblersystem { 'somehost':
  ensure     => present,
  profile    => 'CentOS-6.5-x86_64',
  interfaces => { 'eth0' => {
      mac_address      => 'AA:BB:CC:DD:EE:F0',
      interface_type   => 'bond_slave',
      interface_master => 'bond0',
      static           => true,
      management       => true,
    },
    'eth1' => {
      mac_address      => 'AA:BB:CC:DD:EE:F1',
      interface_type   => 'bond_slave',
      interface_master => 'bond0',
      static           => true,
    },
    'bond0' => {
      ip_address     => '192.168.1.210',
      netmask        => '255.255.255.0',
      static         => true,
      interface_type => 'bond',
      bonding_opts   => 'miimon=300 mode=1 primary=em1',
    },
  },
  netboot    => true,
  gateway    => '192.168.1.1',
  hostname   => 'somehost.example.com',
  require    => Service[$cobbler::service_name],
}
