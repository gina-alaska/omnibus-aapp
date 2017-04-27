#
# Copyright 2015 YOUR NAME
#
# All Rights Reserved.
#

name "aapp"
maintainer "UAF-GINA"
homepage "http://gina.alaska.edu"

# Defaults to C:/aapp on Windows
# and /opt/aapp on all other platforms
install_dir "#{default_root}/#{name}"

Omnibus::Config.append_timestamp(false)
build_version "7.15"
build_iteration 1

# Creates required build directories
#dependency "preparation"

# aapp dependencies/components
override :mpfr, version: '3.1.3'
runtime_dependency "libgfortran"
dependency "aapp"
dependency "metopizer"

# Version manifest file
# dependency "version-manifest"

exclude "**/.git"
exclude "**/bundler/git"

# Nasty hack. Don't want to rebuild gcc for fortran support.
libs = Omnibus::HealthCheck::WHITELIST_LIBS.dup
Omnibus::HealthCheck.send(:remove_const, :WHITELIST_LIBS)
libs << "libgfortran.so.3"
Omnibus::HealthCheck.const_set(:WHITELIST_LIBS, libs)
