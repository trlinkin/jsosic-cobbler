# Class: cobbler::web
#
# This module manages Cobbler
# https://fedorahosted.org/cobbler/
#
# Requires:
#   $cobbler_listen_ip be set in the nodes manifest, else defaults
#   to $ipaddress_eth1
#
class cobbler::web (
  $package_ensure   = $::cobbler::package_ensure,
  $dependency_class = $::cobbler::web::dependency_class,
) inherits cobbler::params {

  # include dependencies
  if $::cobbler::web::dependency_class != undef {
    include $::cobbler::web::dependency_class
  }

  if $::cobbler::params::package_name_web == undef {
    fail("If you include cobbler::web, you must define \$::cobbler::params::package_name_web for ${osfamily}.")
  }
  if $::cobbler::params::django_package {
    package { 'Django':
      ensure   => installed,
      provider => $::cobbler::params::django_package_provider,
      source   => $::cobbler::params::django_package,
      before   => Package[$::cobbler::params::package_name_web],
    }
  }
  package { $::cobbler::params::package_name_web:
    ensure => $package_ensure,
  }
  file { "${::cobbler::params::http_config_prefix}/cobbler_web.conf":
    ensure  => $::cobbler::params::cobbler_web_ensure_type,
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Package[$::cobbler::params::package_name_web],
  }
}
