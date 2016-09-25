#
# = Class: tsm::manual
#
# Used if tsm::manual set to true
#
class tsm::manual (
  $append    = undef,
  $opt       = undef,
  $opta      = undef,
  $inclexcl  = undef,
  $inclexcla = undef,
){

  ::concat::fragment{ 'dsm.sys.append':
    target => $::tsm::params::file_dsm_sys,
    source => "puppet:///private/${append}",
    order  => '15',
    noop   => true,
  }

  File {
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0600',
  }

  if $opt {
    file { "${opt}":
      source => "puppet:///private/${opt}",
    }
  }

  if $inclexcl {
    file { "${inclexcl}":
      source => "puppet:///private/${inclexcl}",
    }
  }

  if $opta {
    file { "${opta}":
      source => "puppet:///private/${opta}",
    }
  }

  if $inclexcla {
    file { "${inclexcla}":
      source => "puppet:///private/${inclexcla}",
    }
  }

}
