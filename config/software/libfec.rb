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
name "libfec"
default_version "3.0.1"

# A software can specify more than one version that is available for install
version("3.0.1") { source md5: "52846b9eac4080e68ade7d2bd13eb504" }

# Sources may be URLs, git locations, or path locations
source url: "http://www.ka9q.net/code/fec/fec-3.0.1.tar.bz2"


# This is the path, inside the tarball, where the source resides
relative_path "fec-#{version}"


build do
  # Setup a default environment from Omnibus - you should use this Omnibus
  # helper everywhere. It will become the default in the future.
  env = with_standard_compiler_flags(with_embedded_path)
  env['CFLAGS'] += " -fPIC"
  # "command" is part of the build DSL. There are a number of handy options
  # available, such as "copy", "sync", "ruby", etc. For a complete list, please
  # consult the Omnibus gem documentation.
  #
  # "install_dir" is exposed and refers to the top-level projects +install_dir+
  command [ "./configure",
            "--prefix=#{install_dir}/embedded" ].join(" "), env: env
  patch source: 'dotprod.patch'
  patch source: 'makefile.patch'
  # You can have multiple steps - they are executed in the order in which they
  # are read.
  #
  # "workers" is a DSL method that returns the most suitable number of
  # builders for the currently running system.
  command "make", env: env
  command "make install", env: env
end
