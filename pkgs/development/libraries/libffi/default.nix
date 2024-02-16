{ lib, stdenv, fetchurl, fetchpatch
, autoreconfHook

  # test suite depends on dejagnu which cannot be used during bootstrapping
  # dejagnu also requires tcl which can't be built statically at the moment
, doCheck ? !(stdenv.hostPlatform.isStatic)
, dejagnu
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "libffi";
  version = "3.4.6";

  src = fetchurl {
    url = "https://github.com/libffi/libffi/releases/download/v${version}/${pname}-${version}.tar.gz";
    hash = "sha256-sN6p3yPIY6elDoJUQPPr/6vWXfFJcQjl1Dd0eEOJWk4=";
  };

  # Note: this package is used for bootstrapping fetchurl, and thus
  # cannot use fetchpatch! All mutable patches (generated by GitHub or
  # cgit) that are needed here should be included directly in Nixpkgs as
  # files.
  patches = [
  ];

  strictDeps = true;
  outputs = [ "out" "dev" "man" "info" ];

  enableParallelBuilding = true;

  configurePlatforms = [ "build" "host" ];

  configureFlags = [
    "--with-gcc-arch=generic" # no detection of -march= or -mtune=
    "--enable-pax_emutramp"
  ];

  preCheck = ''
    # The tests use -O0 which is not compatible with -D_FORTIFY_SOURCE.
    NIX_HARDENING_ENABLE=''${NIX_HARDENING_ENABLE/fortify3/}
    NIX_HARDENING_ENABLE=''${NIX_HARDENING_ENABLE/fortify/}
  '';

  dontStrip = stdenv.hostPlatform != stdenv.buildPlatform; # Don't run the native `strip' when cross-compiling.

  inherit doCheck;

  nativeCheckInputs = [ dejagnu ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "A foreign function call interface library";
    longDescription = ''
      The libffi library provides a portable, high level programming
      interface to various calling conventions.  This allows a
      programmer to call any function specified by a call interface
      description at run-time.

      FFI stands for Foreign Function Interface.  A foreign function
      interface is the popular name for the interface that allows code
      written in one language to call code written in another
      language.  The libffi library really only provides the lowest,
      machine dependent layer of a fully featured foreign function
      interface.  A layer must exist above libffi that handles type
      conversions for values passed between the two languages.
    '';
    homepage = "http://sourceware.org/libffi/";
    license = licenses.mit;
    maintainers = with maintainers; [ matthewbauer ];
    platforms = platforms.all;
  };
}
