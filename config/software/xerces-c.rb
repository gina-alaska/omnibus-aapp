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
#version("1_7_0") { source md5: "9107751f8f1e79d7e7b1a8e47e4f3a96" }
version("1_7_0") { source md5: "250ba3208901d38c9b5a2afb5495bebf" }
version("3.2.2") { source md5: "7aac41029b0d7a5eadd31cc975b391c2" }

# Sources may be URLs, git locations, or path locations
#source url: "ftp://ftp.eumetsat.int/pub/NWPSAF/aapp_data_files/OPS-LRS/external_libs/xerces-c-src#{version}.tar.gz"
source url: "https://github.com/apache/xerces-c/archive/Xerces-C_1_7_0.tar.gz"
#source url: "http://mirror.olnevhost.net/pub/apache//xerces/c/3/sources/xerces-c-3.2.2.tar.gz"

# This is the path, inside the tarball, where the source resides
#relative_path "xerces-c-#{version}"
relative_path "xerces-c-Xerces-C_1_7_0/src/xercesc"

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
  command "cp iostream.h util/NetAccessors/Socket"
  command "sed -i 's/#include <iostream.h>/#include \"iostream.h\"/' util/NetAccessors/Socket/UnixHTTPURLInputStream.cpp"
  #command "export XERCESCROOT=/var/cache/omnibus/src/xerces-c/xerces-c-src1_7_0/; ./runConfigure -p linux -c gcc -x g++ -r pthread -P #{install_dir}/embedded"
  command "export XERCESCROOT=/var/cache/omnibus/src/xerces-c/xerces-c-Xerces-C_1_7_0/; ./runConfigure -p linux -c gcc -x g++ -r pthread -P #{install_dir}/embedded", env:env
  command "make", env: env
  command "make install", env: env
end
