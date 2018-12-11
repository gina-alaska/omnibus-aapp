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
name "ops-lrs"
default_version "OPS_V8.0-AAPP-l-20180118"

dependency 'flex'
dependency 'xerces-c'
dependency 'fftw'

# A software can specify more than one version that is available for install
version("OPS_V8.0-AAPP-l-20180118") { source md5: "76cd21ecc9a7bed6343566c473c36477" }

# Sources may be URLs, git locations, or path locations
source url: File.dirname(__FILE__) + "/../../tars/OPS_V8.0-AAPP-l-20180118.tgz"

# This is the path, inside the tarball, where the source resides
relative_path "OPS_V8.0-AAPP-l-20180118"

build do
  # Setup a default environment from Omnibus - you should use this Omnibus
  # helper everywhere. It will become the default in the future.
  env = with_standard_compiler_flags(with_embedded_path)

  # "command" is part of the build DSL. There are a number of handy options
  # available, such as "copy", "sync", "ruby", etc. For a complete list, please
  # consult the Omnibus gem documentation.
  #
  # "install_dir" is exposed and refers to the top-level projects +install_dir+
  #command [ "cp 
  command [ "./configure",
	    "--aapp-prefix=#{install_dir}",
            "--fftw-prefix=#{install_dir}/embedded",
            "--prefix=#{install_dir}/ops",
            "--arch=Linux-gfortran ",
            "--optimize=normal",
    	    "--site-id=GINA ",
    	    "--nthreads=2"
            ].join(" "), env: env
  command "make", env: env
  command "make install", env: env
end
