# modules/services/kavita.nix
{...}: {
  services.kavita = {
    enable = true;

    settings = {
      IpAddresses = "127.0.0.1";
      Port = 5000;
      BaseUrl = "/kavita/";
    };

    tokenKeyFile = "/var/lib/kavita/token-key";

    ### create the key ###
    # openssl rand -base64 64 | tr -d '\n' |
    #   sudo tee /var/lib/kavita/token-key >/dev/null
    #
    # sudo chown kavita:kavita /var/lib/kavita/token-key
    # sudo chmod 0400 /var/lib/kavita/token-key
  };
}
