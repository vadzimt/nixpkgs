{ stdenv, fetchurl, file, openssl, mlton
, mysql, postgresql, sqlite, gcc
}:

stdenv.mkDerivation rec {
  name = "urweb-${version}";
  version = "20180616";

  src = fetchurl {
    url = "https://github.com/urweb/urweb/releases/download/${version}/${name}.tar.gz";
    sha256 = "211793601c3ba958f45b81c30035cf5e3c236650e23bdf4503dc6074fc143e12";
  };

  buildInputs = [ openssl mlton mysql.connector-c postgresql sqlite ];

  prePatch = ''
    sed -e 's@/usr/bin/file@${file}/bin/file@g' -i configure
  '';

  configureFlags = [ "--with-openssl=${openssl.dev}" ];

  preConfigure = ''
    export PGHEADER="${postgresql}/include/libpq-fe.h";
    export MSHEADER="${mysql.connector-c}/include/mysql/mysql.h";
    export SQHEADER="${sqlite.dev}/include/sqlite3.h";

    export CC="${gcc}/bin/gcc";
    export CCARGS="-I$out/include \
                   -L${openssl.out}/lib \
                   -L${mysql.connector-c}/lib \
                   -L${postgresql.lib}/lib \
                   -L${sqlite.out}/lib";
  '';

  # Be sure to keep the statically linked libraries
  dontDisableStatic = true;

  meta = {
    description = "Advanced purely-functional web programming language";
    homepage    = "http://www.impredicative.com/ur/";
    license     = stdenv.lib.licenses.bsd3;
    platforms   = stdenv.lib.platforms.linux ++ stdenv.lib.platforms.darwin;
    maintainers = [ stdenv.lib.maintainers.thoughtpolice stdenv.lib.maintainers.sheganinans ];
  };
}
