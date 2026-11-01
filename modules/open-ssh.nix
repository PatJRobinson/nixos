{...}: {
  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      # Carry the originating terminal's Flyline preference across SSH hops.
      AcceptEnv = ["FLYLINE_ENABLE" "FLYLINE_DISABLE"];
      PasswordAuthentication = false;
      AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };
}
