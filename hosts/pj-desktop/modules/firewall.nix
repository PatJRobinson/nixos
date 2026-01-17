{...}: {
  networking = {
    firewall = {
      enable = true;

      allowedTCPPorts = [
        47984
        47989
        47990
        48010
        22
      ];

      allowedUDPPorts = [
        5353 # mDNS, sometimes used by DDS
      ];

      allowedUDPPortRanges = [
        {
          from = 47998;
          to = 48000;
        }
        {
          from = 8000;
          to = 8010;
        }

        # ROS 2 DDS discovery ports
        {
          from = 7400;
          to = 7500;
        }
      ];

      # --- IMPORTANT: allow multicast (ROS 2 discovery) ---
      extraCommands = ''
        # Allow multicast groups used by DDS
        iptables -A INPUT -d 224.0.0.0/4 -j ACCEPT
        iptables -A INPUT -d 239.0.0.0/8 -j ACCEPT
      '';
    };
  };
}
