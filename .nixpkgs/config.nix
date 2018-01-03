{ pkgs }: {

  packageOverrides = super: let self = super.pkgs; in with self; rec {
    newsboat-dev = callPackage ./pkgs/newsboat { };
  };
}
