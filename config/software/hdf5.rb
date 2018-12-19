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
name "hdf5"
default_version "1.10.4"

# A software can specify more than one version that is available for install
version("1.10.4") { source md5: "cdf02e61f0d9920a7e7183aa0fb35429" }

# Sources may be URLs, git locations, or path locations
#source url: "http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-#{version}.tar.gz"
source path: File.dirname(__FILE__) + "/../../tars/hdf5-#{version}"


# This is the path, inside the tarball, where the source resides
relative_path "hdf5-#{version}"

dependency 'zlib'
dependency 'szip'

build do
  # Setup a default environment from Omnibus - you should use this Omnibus
  # helper everywhere. It will become the default in the future.
  env = with_standard_compiler_flags(with_embedded_path)

  # "command" is part of the build DSL. There are a number of handy options
  # available, such as "copy", "sync", "ruby", etc. For a complete list, please
  # consult the Omnibus gem documentation.
  #
  # "install_dir" is exposed and refers to the top-level projects +install_dir+
  command ["./configure",
           "--prefix=#{install_dir}/embedded",
           "--enable-fortran",
           "--with-szlib=#{install_dir}/embedded"].join(" "), env: env

  # You can have multiple steps - they are executed in the order in which they
  # are read.
  #
  # "workers" is a DSL method that returns the most suitable number of
  # builders for the currently running system.
  command "make", env: env
  command "make install", env: env
end
