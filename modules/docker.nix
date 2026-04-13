{enableDocker, ...}: {
  virtualisation.docker.enable =
    if enableDocker
    then true
    else false;
}
