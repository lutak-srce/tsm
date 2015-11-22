# Class: tsm::manual
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

  concat::fragment{ 'dsm.sys.append':
    target => $::tsm::params::file_dsm_sys,
    source => "puppet:///private/$append",
    order  => '15',
    noop   => true,
  }

  if $opt {
    file { "$opt":
      ensure => file,
      source => "puppet:///private/$opt",
      owner  => root,
      group  => root,
      mode   => '0600',
    }
  }

  if $inclexcl {
    file { "$inclexcl":
      ensure => file,
      source => "puppet:///private/$inclexcl",
      owner  => root,
      group  => root,
      mode   => '0600',
    }
  }

  if $opta {
    file { "$opta":
      ensure => file,
      source => "puppet:///private/$opta",
      owner  => root,
      group  => root,
      mode   => '0600',
    }
  }

  if $inclexcla {
    file { "$inclexcla":
      ensure => file,
      source => "puppet:///private/$inclexcla",
      owner  => root,
      group  => root,
      mode   => '0600',
    }
  }


}
