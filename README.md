# NixOS Config Generator

Reusable NixOS + Home Manager config builder.

This repo provides functions to build systems (`mkHost`) and user configs (`mkHome`), while keeping machine-specific config in a separate local flake.

---

## Idea

- This repo = shared logic + modules  
- Your local flake = host-specific + sensitive config  

Benefits:
- no secrets in git  
- reusable config across machines  
- reproducible builds (shared `flake.lock` commited to this repo)

---

## Usage

Set up a local directory, e.g.:

```
mkdir -p ~/nixos/config
```

Clone this repo:

```
git clone https://github.com/PatJRobinson/nixos.git ~/nixos/config-generator
```

Copy the example flake:

```
cp ~/nixos/config-generator/local-flake-example.nix ~/nixos/config/flake.nix
```

Modify the example with your user name, host name, and configuration options
Make sure the flake input `config-generator` points to the correct path

Then, build and apply the config:

```
cd ~/nixos/config
nix flake update
sudo nixos-rebuild switch --flake .#<hostname>
home-manager switch --flake .#<user>@<hostname>
```

⚠️ Warning: Ensure userName matches a user defined in your current NixOS configuration (users.users). 
If not, you risk locking yourself out.

---

## Inputs

### mkHostCfg

Defines system parameters:

```
{
  hostName = "host";
  channel = "25.11" | "unstable";
  flakePath = self.outPath;
  gpuSupport = "nvidia" | "amd" | "intel" | null;

  hostParams = {
    wm.type = "hypr";
    wm.displayParams.displayType = "dual";
  };
}
```

---

### mkHome

Defines user config:

```
{
  userName = "user";

  gitCfg = { ... };   # programs.git
  sshCfg = { ... };   # programs.ssh
  envVars = { ... };  # sessionVariables
}
```

---

## Structure

```
flake.nix                       # builder functions
hosts/base-configuration.nix    # base configuration file
users/                          # home-manager config
modules/                        # shared modules
```

---
