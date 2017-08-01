{ stdenv, fetchgit, sqlite, curl, pkgconfig, libxml2, stfl, json-c-0-11, ncurses
, gettext, libiconv, makeWrapper, perl }:

stdenv.mkDerivation rec {
  name = "newsbeuter-dev-20170722";

  src = fetchgit {
    url = "https://github.com/akrennmair/newsbeuter.git";
    rev = "d20cf49a5b83ed209ca08def2629aae669e16b08";
    sha256 = "1b138sarxi02djl1cgc687hp7wf4z87693frfsv85nf4n5gdnn5y";
  };


  buildInputs
    # use gettext instead of libintlOrEmpty so we have access to the msgfmt
    # command
    = [ pkgconfig sqlite curl libxml2 stfl json-c-0-11 ncurses gettext perl libiconv ]
      ++ stdenv.lib.optional stdenv.isDarwin makeWrapper;

  preBuild = ''
    sed -i -e 107,113d config.sh
    sed -i "1 s%^.*$%#!${perl}/bin/perl%" txt2h.pl
    export LDFLAGS=-lncursesw
  '';

  enableParallelBuilding = true;

  installFlags = [ "DESTDIR=$(out)" "prefix=" ];

  postInstall = stdenv.lib.optionalString stdenv.isDarwin ''
    for prog in $out/bin/*; do
      wrapProgram "$prog" --prefix DYLD_LIBRARY_PATH : "${stfl}/lib"
    done
  '';

  meta = {
    homepage    = http://www.newsbeuter.org;
    description = "An open-source RSS/Atom feed reader for text terminals";
    maintainers = with stdenv.lib.maintainers; [ ];
    license     = stdenv.lib.licenses.mit;
    platforms   = stdenv.lib.platforms.unix;
  };
}
