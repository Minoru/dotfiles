{ stdenv, fetchgit, sqlite, curl, pkgconfig, libxml2, stfl, json-c-0-11, ncurses
, gettext, libiconv, asciidoc, docbook_xml_xslt, docbook_xml_dtd_45, libxslt
, makeWrapper }:

stdenv.mkDerivation rec {
  name = "newsboat-dev-20171022-2";

  src = fetchgit {
    url = "https://github.com/newsboat/newsboat.git";
    rev = "b6c3eb5ba9f93afbf1eaf1503c46e7e96e83f8f8";
    sha256 = "12w9f6z6qicz52jix556sczgc5adn1g859wiag0avihgzqqa3aik";
    leaveDotGit = true;
  };

  buildInputs
    # use gettext instead of libintlOrEmpty so we have access to the msgfmt
    # command
    = [ pkgconfig sqlite curl libxml2 stfl json-c-0-11 ncurses gettext libiconv
        asciidoc docbook_xml_xslt docbook_xml_dtd_45 libxslt ]
      ++ stdenv.lib.optional stdenv.isDarwin makeWrapper;

  preBuild = ''
    export CXXFLAGS='-DGIT_HASH=\"r2.10.1-53-gb6c3e\"'
    sed -i -e 's/-ggdb/-O3/; s/-fprofile-arcs -ftest-coverage//' Makefile
  '';

  enableParallelBuilding = true;

  installFlags = [ "DESTDIR=$(out)" "prefix=" ];

  postInstall = stdenv.lib.optionalString stdenv.isDarwin ''
    for prog in $out/bin/*; do
      wrapProgram "$prog" --prefix DYLD_LIBRARY_PATH : "${stfl}/lib"
    done
  '';

  meta = {
    homepage    = https://newsboat.org;
    description = "An open-source RSS/Atom feed reader for text terminals";
    maintainers = with stdenv.lib.maintainers; [ ];
    license     = stdenv.lib.licenses.mit;
    platforms   = stdenv.lib.platforms.unix;
  };
}
