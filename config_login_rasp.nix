{ config, lib, pkgs, ... }:
{
  ### This file contains the configuration for logins (users, ssh) for the frontend raspberry
  # The goal is to configure as much things as possible in this repository, to do minimal changes on the computer
  # See the README.md file to get an introduction on Nix/NixOs

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pi = {
    isNormalUser = true;
    # In theory one should use hashedPassword but who care, the password is public anyway
    password = "cwifoosball";
    extraGroups = [ "wheel" "audio"  ]; # Enable ‘sudo’ for the user.
    # For ssh access
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDjQGQzn3+PxNGMdcw+uwFUMaQpqExnM2mkL3lyAjvc3ytyNfWIIVHqOh/s5PcPmjtGvUHtrPHi+6uFa0zIWJL2DLAGJ7t3Cy1yCStJsGyquxe1Th2X1h02mEL+yDKxfSYC8AWWpG/WoiwkIHhiMsmP5tNGtRikBZp8I0GxvNLbC0UpLZ5jHxrvxu6sKCxHerMt96wwJng7NI/YwfdZd8Z/fuCOYwqIgf/d0El0nMZjYCtn0b5s87c3EI6+ViYm0z9XyD5tLiXJleF8odTS6YkrFZpgkO4yoqPJPkuudMDuozx2iFVcamR1B8YLNOVLV/BupnoMULN80y+EyAa1x5hO0QLr22lk6zoCWmkfDz5lhvriyW5mLxD1TTo94aabhS8tGMoR1f1kuy5/GtT/rn0GO03fcTjRQP2c/uQeYwCwPTPQBwlVwidwAtd2Re8FWk0uYqKkvgV6GTit1AwYBiqQStZrzcbyov4vHzhOaNpcgslnF1Xmk7R2FMsH7zxEeBk= leo@bestos"
    ];
  };
  # Enable the OpenSSH server.
  services.openssh = {
    enable = true;
    # Forbid password authentication (too much risks with a trivial password), use keys instead
    passwordAuthentication = false;
  };


}
