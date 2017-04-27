#
# Copyright 2015 YOUR NAME
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# These options are required for all software definitions
name "metopizer"
default_version "3.51.1"

# A software can specify more than one version that is available for install
version("3.51.1") { source md5: "e91ac07bedcd53f3dec6c5a5c166ec66"}

# Sources may be URLs, git locations, or path locations
source url: "http://hippy.gina.alaska.edu/distro/metopizer-#{version}.tar.gz"


# This is the path, inside the tarball, where the source resides
relative_path "metopizer-#{version}"

# dependency 'gcc-gfortran'
dependency 'libfec'
dependency 'libxml2'
dependency 'libjpeg'

build do
  # Setup a default environment from Omnibus - you should use this Omnibus
  # helper everywhere. It will become the default in the future.
  env = with_standard_compiler_flags(with_embedded_path)

  # "command" is part of the build DSL. There are a number of handy options
  # available, such as "copy", "sync", "ruby", etc. For a complete list, please
  # consult the Omnibus gem documentation.
  #
  # "install_dir" is exposed and refers to the top-level projects +install_dir+
  command [ "./configure",
            "--prefix=#{install_dir}" ].join(" "), env: env

  # You can have multiple steps - they are executed in the order in which they
  # are read.
  #
  # "workers" is a DSL method that returns the most suitable number of
  # builders for the currently running system.
  command "make", env: env
  command "make install", env: env
end
