# Class: tsm::params
#
# This module contains defaults for tsm modules
#
class tsm::params {

  $ensure           = 'present'
  $version          = undef
  $backup_status    = 'enabled'
  $archive_status   = 'enabled'
  $file_mode        = '0600'
  $file_owner       = 'root'
  $file_group       = 'root'
  $autorestart      = true
  $dependency_class = 'tsm::dependency'
  $my_class         = undef
  $manual           = false

  $backup_server    = 'backup.example.com'
  $archive_server   = 'archive.example.com'

  $backup_options   = {}
  $archive_options  = {}

  $nodename         = $::fqdn

  # install package depending on major version
  case $::osfamily {
    default: {}
    /(RedHat|redhat|amazon|Debian|debian|Ubuntu|ubuntu)/: {
      $package           = 'tsm-client'
      $backup_service    = 'dsmcad-backup'
      $archive_service   = 'dsmcad-archive'
      $file_dsm_sys      = '/etc/tsm-client/dsm.sys'
      $file_backup_excl  = '/etc/tsm-client/dsm-inclexcl.backup'
      $file_archive_excl = '/etc/tsm-client/dsm-inclexcl.archive'
      $file_backup_opt  = '/etc/tsm-client/dsm-backup.opt'
      $file_archive_opt = '/etc/tsm-client/dsm-archive.opt'
    }
    #/(debian|ubuntu)/: {
    #}
  }

}
