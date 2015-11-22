#
# = Class: tsm
#
# This class manages Tivoli Storage Manger Backup/Archive client
#
#
# == Parameters
#
# [*ensure*]
#   Type: string, default: 'present'
#   Manages package installation and class resources. Possible values:
#   * 'present' - Install package, ensure files are present (default)
#   * 'absent'  - Stop service and remove package and managed files
#
# [*package*]
#   Type: string, default on $::osfamily basis
#   Manages the name of the package.
#
# [*version*]
#   Type: string, default: undef
#   If this value is set, the defined version of package is installed.
#   Possible values are:
#   * 'x.y.z' - Specific version
#   * latest  - Latest available
#
# [*nodename*]
#   Type: string, default: $::fqdn
#   Name of the node, used as client name when connecting to backup/archive
#   server.
#
# [*backup_server*]
# [*archive_server*]
#   Type: string, default: 'backup.example.com'
#   Type: string, default: 'archive.example.com'
#   Name or IP address of the backup/archive server.
#
# [*backup_password*]
# [*archive_password*]
#   Type: string, default: 'UNSET'
#   Password for backup (or archive) client. If password is 'UNSET', client
#   will use 'passwordaccess generate' option, which will ask for password
#   at first manual connect to backup/archive server and store it in file.
#
# [*backup_service*]
# [*archive_service*]
#   Type: string, defaults on $::osfamily basis
#   Name of the backup (or archive) service. Defaults are provided on
#   $::osfamily basis.
#
# [*backup_status*]
# [*archive_status*]
#   Type: string, default: 'enabled'
#   Define the provided service status. Available values affect both the
#   ensure and the enable service arguments:
#   * 'enabled':     ensure => running, enable => true
#   * 'disabled':    ensure => stopped, enable => false
#   * 'running':     ensure => running, enable => undef
#   * 'stopped':     ensure => stopped, enable => undef
#   * 'activated':   ensure => undef  , enable => true
#   * 'deactivated': ensure => undef  , enable => false
#   * 'unmanaged':   ensure => undef  , enable => undef
#
# [*backup_exclude*]
# [*archive_exclude*]
#   Type: array, default: []
#   List of directories or files that will be excluded from backing up
#   (archiving). Default is empty array.
#
# [*file_backup_excl*]
# [*file_archive_excl*]
#   Type: string, defaults on $::osfamily basis
#   Path to file which has list of excluded files. Defaults are provided
#   on $::osfamily basis.
#
# [*file_mode*]
# [*file_owner*]
# [*file_group*]
#   Type: string, default: '0600'
#   Type: string, default: 'root'
#   Type: string, default 'root'
#   File permissions and ownership information assigned to config files.
#
# [*file_dsm_sys*]
#   Type: string, default on $::osfamily basis
#   Path to dsm.sys.
#
# [*dependency_class*]
#   Type: string, default: tsm::dependency
#   Name of a class that contains resources needed by this module but provided
#   by external modules. Set to undef to not include any dependency class.
#
# [*my_class*]
#   Type: string, default: undef
#   Name of a custom class to autoload to manage module's customizations
#
# [*noops*]
#   Type: boolean, default: undef
#   Set noop metaparameter to true for all the resources managed by the module.
#   If true no real change is done is done by the module on the system.
#
class tsm (
  $ensure            = $::tsm::params::ensure,
  $package           = $::tsm::params::package,
  $version           = $::tsm::params::version,
  $nodename          = $::tsm::params::nodename,
  $backup_server     = $::tsm::params::backup_server,
  $backup_password   = 'UNSET',
  $backup_service    = $::tsm::params::backup_service,
  $backup_status     = $::tsm::params::backup_status,
  $backup_exclude    = [],
  $file_backup_excl  = $::tsm::params::file_backup_excl,
  $archive_server    = $::tsm::params::archive_server,
  $archive_password  = 'UNSET',
  $archive_service   = $::tsm::params::archive_service,
  $archive_status    = $::tsm::params::archive_status,
  $archive_exclude   = [],
  $file_archive_excl = $::tsm::params::file_archive_excl,
  $file_mode         = $::tsm::params::file_mode,
  $file_owner        = $::tsm::params::file_owner,
  $file_group        = $::tsm::params::file_group,
  $file_dsm_sys      = $::tsm::params::file_dsm_sys,
  $dependency_class  = $::tsm::params::dependency_class,
  $my_class          = $::tsm::params::my_class,
  $manual            = $::tsm::params::manual,
  $backup_options    = $::tsm::params::backup_options,
  $archive_options   = $::tsm::params::archive_options,
  $noops             = undef,
  $virtualmountpoint = [],
) inherits tsm::params {

  ### Input parameters validation
  validate_re($ensure, ['present','absent'], 'Valid values are: present, absent')
  validate_string($package)
  validate_string($version)
  validate_string($backup_server)
  validate_string($backup_service)
  validate_re($backup_status,  ['enabled','disabled','running','stopped','activated','deactivated','unmanaged'], 'Valid values are: enabled, disabled, running, stopped, activated, deactivated and unmanaged')
  validate_string($archive_server)
  validate_string($archive_service)
  validate_re($archive_status, ['enabled','disabled','running','stopped','activated','deactivated','unmanaged'], 'Valid values are: enabled, disabled, running, stopped, activated, deactivated and unmanaged')
  validate_string($nodename)

  ### Internal variables (that map class parameters)
  if $ensure == 'present' {
    $package_ensure = $version ? {
      ''      => 'present',
      default => $version,
    }
    $backup_service_enable = $backup_status ? {
      'enabled'     => true,
      'disabled'    => false,
      'running'     => undef,
      'stopped'     => undef,
      'activated'   => true,
      'deactivated' => false,
      'unmanaged'   => undef,
    }
    $backup_service_ensure = $backup_status ? {
      'enabled'     => 'running',
      'disabled'    => 'stopped',
      'running'     => 'running',
      'stopped'     => 'stopped',
      'activated'   => undef,
      'deactivated' => undef,
      'unmanaged'   => undef,
    }
    $archive_service_enable = $archive_status ? {
      'enabled'     => true,
      'disabled'    => false,
      'running'     => undef,
      'stopped'     => undef,
      'activated'   => true,
      'deactivated' => false,
      'unmanaged'   => undef,
    }
    $archive_service_ensure = $archive_status ? {
      'enabled'     => 'running',
      'disabled'    => 'stopped',
      'running'     => 'running',
      'stopped'     => 'stopped',
      'activated'   => undef,
      'deactivated' => undef,
      'unmanaged'   => undef,
    }

    $file_ensure = present
  } else {
    $package_ensure = 'absent'
    $backup_service_enable = undef
    $backup_service_ensure = stopped
    $archive_service_enable = undef
    $archive_service_ensure = stopped
    $file_ensure    = absent
  }

  ### Extra classes
  if $dependency_class { include $dependency_class }
  if $my_class         { include $my_class         }

  package { 'tsm-client':
    ensure => $package_ensure,
    name   => $package,
    noop   => $noops,
  }

  service { 'dsmcad-backup':
    ensure  => $backup_service_ensure,
    enable  => $backup_service_enable,
    require => Package['tsm-client'],
    noop    => $noops,
  }

  service { 'dsmcad-archive':
    ensure  => $archive_service_ensure,
    enable  => $archive_service_enable,
    require => Package['tsm-client'],
    noop    => $noops,
  }

  # set defaults for file resource in this scope.
  File {
    ensure  => $file_ensure,
    owner   => $file_owner,
    group   => $file_group,
    mode    => $file_mode,
    noop    => $noops,
  }

  # Ugly hack - giving ability to append to dsm.sys by including tsm::manual
  concat { $file_dsm_sys:
    owner => $file_owner,
    group => $file_group,
    mode  => $file_mode,
    noop  => $noops,
  }

  concat::fragment{ 'dsm.sys':
    target  => $file_dsm_sys,
    content => template('tsm/dsm.sys.erb'),
    order   => '01',
  }

  if $manual == true       { include tsm::manual }

  file { $file_backup_excl :
    content => template('tsm/dsm-inclexcl.backup.erb'),
  }

  file { $file_archive_excl :
    content => template('tsm/dsm-inclexcl.archive.erb'),
  }

}
# vi:syntax=puppet:filetype=puppet:ts=4:et:nowrap:
