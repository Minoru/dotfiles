{ stdenv, fetchgit, sqlite, curl, pkgconfig, libxml2, stfl, json-c-0-11, ncurses
, gettext, libiconv, asciidoc, docbook_xml_xslt, docbook_xml_dtd_45, libxslt
, makeWrapper, git }:

stdenv.mkDerivation rec {
  name = "newsboat-dev-20171210-1";

  src = fetchgit {
    url = "https://github.com/newsboat/newsboat.git";
    rev = "5f3ce08b10dc1977ebbb4113e5b23efb94f669cd";
    sha256 = "1sq2fxgnmwi8c6kzrgr1nz17sii8az3y6zw2l4dw7pgp0wh3180n";
    leaveDotGit = true;
  };

  buildInputs
    # use gettext instead of libintlOrEmpty so we have access to the msgfmt
    # command
    = [ pkgconfig sqlite curl libxml2 stfl json-c-0-11 ncurses gettext libiconv
        asciidoc docbook_xml_xslt docbook_xml_dtd_45 libxslt git ]
      ++ stdenv.lib.optional stdenv.isDarwin makeWrapper;

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
