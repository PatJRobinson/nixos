{
  pkgs,
  config,
  enableDocker,
  ...
}: let
  # Workaround for an NVIDIA DisplayPort audio quirk.
  #
  # On one test machine, after boot/resume the monitor speakers sometimes output
  # static until the NVIDIA HDMI/DP audio device is opened once. Playing a very
  # short silent WAV directly through ALSA "wakes" the audio path without making
  # audible noise or depending on the desktop session / PipeWire being ready.
  #
  # If the monitor/GPU port changes, re-check with:
  #   aplay -l
  # and update this device if needed.
  nvidiaAudioPoke = pkgs.writeShellScript "nvidia-audio-poke" ''
    set -u

    wav=/run/nvidia-audio-poke-silence.wav

    if [ ! -e "$wav" ]; then
      ${pkgs.sox}/bin/sox -n -r 48000 -c 2 "$wav" trim 0 0.25 vol 0
    fi

    # Change DEV=3 to the NVIDIA HDMI/DP ALSA device that works for your monitor.
    ${pkgs.alsa-utils}/bin/aplay -q -D "plughw:CARD=NVidia,DEV=3" "$wav" || true
  '';
in {
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # docker
  hardware.nvidia-container-toolkit.enable =
    if enableDocker
    then true
    else false;
  virtualisation.docker.daemon.settings.features.cdi =
    if enableDocker
    then true
    else false;

  environment.systemPackages = with pkgs; [
    alsa-utils
    sox
  ];

  systemd.services.nvidia-audio-poke-boot = {
    description = "Poke NVIDIA DP audio after boot";
    wantedBy = ["multi-user.target"];
    after = ["sound.target"];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = nvidiaAudioPoke;
    };
  };

  systemd.services.nvidia-audio-poke-resume = {
    description = "Poke NVIDIA DP audio after resume";
    wantedBy = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];

    after = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = nvidiaAudioPoke;
    };
  };
}
