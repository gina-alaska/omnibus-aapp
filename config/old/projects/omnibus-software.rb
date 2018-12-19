#
# Copyright 2017 YOUR NAME
#
# All Rights Reserved.
#

name "omnibus-software"
maintainer "CHANGE ME"
homepage "https://CHANGE-ME.com"

# Defaults to C:/omnibus-software on Windows
# and /opt/omnibus-software on all other platforms
install_dir "#{default_root}/#{name}"

build_version Omnibus::BuildVersion.semver
build_iteration 1

# Creates required build directories
dependency "preparation"

# omnibus-software dependencies/components
# dependency "somedep"

# Version manifest file
dependency "version-manifest"

exclude "**/.git"
exclude "**/bundler/git"
