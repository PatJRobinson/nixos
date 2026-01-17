{pkgs, ...}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "keifu";
  version = "0.2.2";

  src = pkgs.fetchFromGitHub {
    owner = "trasta298";
    repo = "keifu";
    rev = "v${version}"; # or a commit hash
    sha256 = "sha256-jMUhg3irMzTPV0TKaZU6/jiKCMAQLF0SJTUJdub4IA4=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    # if the lock has git deps, you may need outputHashes here
    # outputHashes = { "crate-name-version" = "sha256-..."; };
  };

  nativeBuildInputs = with pkgs; [pkg-config perl];
  buildInputs = [pkgs.openssl];

  meta = with pkgs.lib; {
    description = "keifu (系譜, /keːɸɯ/) is a terminal UI tool that visualizes Git commit graphs. It shows a colored commit graph, commit details, and a summary of changed files, and lets you perform basic branch operations.";
    license = licenses.mit;
    mainProgram = "keifu";
  };
}
