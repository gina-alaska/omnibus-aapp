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
name "xerces-c"
default_version "1_7_0"

# A software can specify more than one version that is available for install
version("1_7_0") { source md5: "9107751f8f1e79d7e7b1a8e47e4f3a96" }

# Sources may be URLs, git locations, or path locations
source url: "https://nwpsaf.eu/downloads/aapp_data_files/OPS-LRS/external_libs/xerces-c-src#{version}.tar.gz"

# This is the path, inside the tarball, where the source resides
relative_path "xerces-c-src#{version}"

build do
  # Setup a default environment from Omnibus - you should use this Omnibus
  # helper everywhere. It will become the default in the future.
  env = with_standard_compiler_flags(with_embedded_path)

  # "command" is part of the build DSL. There are a number of handy options
  # available, such as "copy", "sync", "ruby", etc. For a complete list, please
  # consult the Omnibus gem documentation.
  #
  # "install_dir" is exposed and refers to the top-level projects +install_dir+

  command "wget  https://nwpsaf.eu/downloads/aapp_data_files/OPS-LRS/external_libs/iostream.h"
  command "cp iostream.h src/xercesc/util/NetAccessors/Socket"
  command "sed -i 's/#include <iostream.h>/#include \"iostream.h\"/' src/xercesc/util/NetAccessors/Socket/UnixHTTPURLInputStream.cpp"
  command " export XERCESCROOT=$BUILD/$dir; ./runConfigure -p linux -c gcc -x g++ -r pthread -P #{install_dir}/embedded"
  command "make", env: env
  command "make install", env: env
end
