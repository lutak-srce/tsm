# Class: tsm::dependency
#
# This class contains extra resources needed by this module
# and provided by other modules.
# They are needed by the module, but you may provide them
# in alternative ways.
# With the dependency_class parameter you can specify the
# name of a custom class where you provide the same
# resources using custom code or modules.
#
# == Usage
#
# This class is not intended to be used directly.
#
class tsm::dependency {

  # install package depending on major version
  case $::osfamily {
    default: {}
    /(redhat|amazon)/: {
      include yum::repo::srce::intern
    }
    /(debian|ubuntu)/: {
    }
  }

}
