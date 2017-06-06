{ pkgs }: {

  packageOverrides = super: let self = super.pkgs; in with self; rec {
    newsbeuter-dev = callPackage ./pkgs/newsbeuter { };
  };
}
