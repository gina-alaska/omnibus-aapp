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
name "bison"
default_version "3.2.2"

# A software can specify more than one version that is available for install
version("3.2") { source md5: "094f88d1e35d7e3116d91d7d8863bcde" }
version("3.2.2") { source md5: "f45afb3af824e8548bc6858d71612321" }

# Sources may be URLs, git locations, or path locations
#source url: "https://github.com/westes/flex/archive/flex-#{version}.tar.gz"
source url: "ftp://prep.ai.mit.edu/pub/gnu/bison/bison-#{version}.tar.gz"


# This is the path, inside the tarball, where the source resides
relative_path "bison-#{version}"

build do
  # Setup a default environment from Omnibus - you should use this Omnibus
  # helper everywhere. It will become the default in the future.
  env = with_standard_compiler_flags(with_embedded_path)

  #command "./autogen.sh"

  command [ "./configure",
            "--prefix=#{install_dir}/embedded",
            ].join(" "), env: env

  # You can have multiple steps - they are executed in the order in which they
  # are read.
  #
  # "workers" is a DSL method that returns the most suitable number of
  # builders for the currently running system.
  command "make", env: env
  command "make install", env: env
end
