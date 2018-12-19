name "szip"
default_version "2.1.1"

# A software can specify more than one version that is available for install
version("2.1.1") { source md5: "5addbf2a5b1bf928b92c47286e921f72" } 

# Sources may be URLs, git locations, or path locations
source path:  File.dirname(__FILE__) + "/../../tars/szip-#{version}"

# This is the path, inside the tarball, where the source resides
relative_path "szip-#{version}"

build do
  # Setup a default environment from Omnibus - you should use this Omnibus
  # helper everywhere. It will become the default in the future.
  env = with_standard_compiler_flags(with_embedded_path)

  # "command" is part of the build DSL. There are a number of handy options
  # available, such as "copy", "sync", "ruby", etc. For a complete list, please
  # consult the Omnibus gem documentation.
  #
  # "install_dir" is exposed and refers to the top-level projects +install_dir+
  command "./configure" \
          " --prefix=#{install_dir}/embedded", env: env

  # You can have multiple steps - they are executed in the order in which they
  # are read.
  #
  # "workers" is a DSL method that returns the most suitable number of
  # builders for the currently running system.
  command "make", env: env
  command "make install", env: env
end
