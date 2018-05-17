{ stdenv, fetchgit, sqlite, curl, pkgconfig, libxml2, stfl, json_c, ncurses
, gettext, libiconv, asciidoc, docbook_xml_xslt, docbook_xml_dtd_45, libxslt
, makeWrapper, git }:

stdenv.mkDerivation rec {
  name = "newsboat-dev-20180512-1";

  src = fetchgit {
    url = "https://github.com/newsboat/newsboat.git";
    rev = "3f270b52f91a08f8830b333ba1e02703debff5fa";
    sha256 = "1i7c9fzz1yf3gjjyc6cmam9b6hkxskf69ql0a5h08kmay1wjw90i";
    leaveDotGit = true;
  };

  buildInputs
    # use gettext instead of libintlOrEmpty so we have access to the msgfmt
    # command
    = [ pkgconfig sqlite curl libxml2 stfl json_c ncurses gettext libiconv
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
