{pkgs, ...}: {
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;

  security.rtkit.enable = true; # Enable RealtimeKit for audio purposes

  services.pipewire = {
    enable = true;
    socketActivation = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # Uncomment the following line if you want to use JACK applications
    # jack.enable = true;

    extraConfig.pipewire."92-gaming-stability" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 512;
        "default.clock.min-quantum" = 512;
        "default.clock.max-quantum" = 1024;
      };
    };

    extraConfig.pipewire-pulse."92-gaming-stability" = {
      "pulse.properties" = {
        "pulse.min.req" = "512/48000";
        "pulse.default.req" = "512/48000";
        "pulse.min.quantum" = "512/48000";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
    sox
  ];
}
