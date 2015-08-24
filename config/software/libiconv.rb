
name "libiconv"
default_version "1.14"

dependency "patch" if solaris2?

source url: "http://ftp.gnu.org/pub/gnu/libiconv/libiconv-#{version}.tar.gz",
       md5: 'e34509b1623cec449dfeb73d7ce9c6c6'

relative_path "libiconv-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  configure_command = "./configure" \
                      " --prefix=#{install_dir}/embedded"
  if aix?
    patch_env = env.dup
    patch_env['PATH'] = "/opt/freeware/bin:#{env['PATH']}"
    patch source: 'libiconv-1.14_srclib_stdio.in.h-remove-gets-declarations.patch', env: patch_env
  else
    patch source: 'libiconv-1.14_srclib_stdio.in.h-remove-gets-declarations.patch'
  end


  command configure_command, env: env

  make "-j #{workers}", env: env
  make "-j #{workers} install-lib" \
          " libdir=#{install_dir}/embedded/lib" \
          " includedir=#{install_dir}/embedded/include", env: env
end
