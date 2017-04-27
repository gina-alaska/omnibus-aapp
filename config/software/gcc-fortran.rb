name "gcc-gfortran"
default_version "4.4.7"

dependency "gmp"
dependency "mpfr"
dependency "mpc"
dependency "libiconv"
dependency "zlib"

version("4.4.7") { source md5: "a755ac748de31dee53a39f54a0adacaf" }
version("4.9.2")      { source md5: "76f464e0511c26c93425a9dcdc9134cf" }

source url: "http://mirrors.kernel.org/gnu/gcc/gcc-#{version}/gcc-#{version}.tar.gz"

relative_path "gcc-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  configure_command = ["./configure",
                       "--prefix=#{install_dir}/embedded",
                       "--disable-nls",
                       "--enable-languages=c,c++,fortran",
                       "--enable-shared",
                       "--disable-multilib",
                       "--disable-bootstrap"]


  command configure_command.join(" "), env: env
  # gcc takes quite a long time to build (over 2 hours) so we're setting the mixlib shellout
  # timeout to 4 hours. It's not great but it's required (on solaris at least, need to verify
  # on any other platforms we may use this with)
  make "-j #{workers}", env: env, timeout: 14400
  make "-j #{workers} install", env: env
end
  # command "./configure" \
  #         " --enable-languages='fortran'" \
  #         " --enable-threads=posix" \
  #         " --enable-shared" \
  #         " --disable-multilib" \
  #         " --disable-bootstrap" \
  #         " --prefix=#{install_dir}/embedded", env: env
