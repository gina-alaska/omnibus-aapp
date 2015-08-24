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
name "aapp"
default_version "7.10"

# A software can specify more than one version that is available for install
version("7.10") { source md5: "59dac969ecb663d207d6571a24010f4b" }

# Sources may be URLs, git locations, or path locations
source url: "http://mirrors.gina.alaska.edu/EUMET/AAPP_full_#{version}.tgz"

# This is the path, inside the tarball, where the source resides
relative_path "AAPP_#{version}"

dependency 'hdf5'
dependency 'bufrdc'
dependency 'grib_api'

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
            "--site-id=GINA",
            "--fortran-compiler=gfortran",
            "--station=gilmore_creek",
            "--station_id=GLC",
            "--external-libs='-L#{install_dir}/embedded/lib -lbufr -lgrib_api_f77 -lgrib_api_f90 -lgrib_api -ljasper -lhdf5 -lsz -lz'",
            "--external-includes='-I#{install_dir}/embedded/include'",
            "--prefix=#{install_dir}"].join(" "), env: env

  # You can have multiple steps - they are executed in the order in which they
  # are read.
  #
  # "workers" is a DSL method that returns the most suitable number of
  # builders for the currently running system.
  command "make", env: env
  command "make install", env: env
end
