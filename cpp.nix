{ pkgs, ...}:

{
  environment.systemPackages = with pkgs; [
    gcc                # g++ toolchain
    llvmPackages_21.clang-unwrapped
    clang-tools        # contains clang-tidy/clang-check (some distros)
    clang-analyzer
    cmake
    ninja
    gnumake42
    ccache
    pkg-config
    lldb
    gdb
    cppcheck
    bear               # to generate compile_commands.json
    python3
    python3Packages.pip
    tree                         # handy tree utility
  ];
  #programs.nix-ld.enable = true; # idk
}
