{stdenv, fetchurl, bashInteractive, readline, ...}:
stdenv.mkDerivation {
  pname = "bash-autosuggestions";
  version = "unstable-2026-07-13";

  # Only the builtin is needed; upstream's loader also contains its setup UI.
  src = fetchurl {
    url = "https://raw.githubusercontent.com/wallentx/bash-autosuggestions/d663277e5cb37259f49f69fa7455cc21946f4d39/src/bash_autosuggestions.c";
    hash = "sha256-cm0obbYvGQUlm7YM5IyT98YE/23JW5LqtqfUiyvII/I=";
  };
  dontUnpack = true;
  buildInputs = [bashInteractive.dev readline];
  buildPhase = ''
    runHook preBuild
    $CC -O2 -fPIC -shared \
      -I${bashInteractive.dev}/include \
      -I${bashInteractive.dev}/include/bash \
      -I${bashInteractive.dev}/include/bash/include \
      -I${bashInteractive.dev}/include/bash/builtins \
      "$src" -o bash-autosuggestions.so -lreadline
    runHook postBuild
  '';
  doCheck = true;
  checkPhase = ''
    runHook preCheck
    ${bashInteractive}/bin/bash --noprofile --norc -c '
      enable -f ./bash-autosuggestions.so bash_autosuggestions
      builtin bash_autosuggestions enable
      builtin bash_autosuggestions status
      builtin bash_autosuggestions uninstall
    '
    runHook postCheck
  '';
  installPhase = ''
    runHook preInstall
    install -Dm755 bash-autosuggestions.so "$out/lib/bash-autosuggestions.so"
    runHook postInstall
  '';
}
