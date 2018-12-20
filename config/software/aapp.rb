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
default_version "7.15"

dependency "automake"
dependency "perl"
dependency "libiconv"
dependency "zlib"

# A software can specify more than one version that is available for install
version("7.15") { source md5: "d49167f094daea4468a734678ea0ffa2" }

# Sources may be URLs, git locations, or path locations
source url: "http://hippy.gina.alaska.edu/distro/AAPP_full_#{version}.tgz"

# This is the path, inside the tarball, where the source resides
relative_path "AAPP_#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)


  1.upto(10).each do |step|
  	command [ File.dirname(__FILE__) +"/install_aapp8.sh",  
		step.to_i ].join(" ")
  end
end
