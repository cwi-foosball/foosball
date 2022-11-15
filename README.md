# Foosball CWI

Hosted on github [here](https://github.com/cwi-foosball/foosball).

This project aims to monitor the computer (raspberry pi) of the foosball system https://foosball.cwi.nl/ at CWI (you need a VPN to access it). In order to ease deployment on new machine (yes a need to create a new machine can happen… it's what I am doing right now since the SD card crashed :-P) I will try to use Nix/NixOs to deploy it and keep track of all the configurations in a central place.

Nix/NixOs brings you many advantages:
- great reproducibility: all versions of all softwares are pinned so everybody should get the same result
- central configuration: all your config is stored in a single repository. Including OS, packages, config…
- easy tests in VM: you can trivially run a VM to test your OS without a need to test it on the raspberry first
- …

## Credits

This project only continues the amazing work done by Tom Bannink (and certainly others, let me know who contributed exactly ^^). You can find the initial project there:
- https://github.com/Tombana/foosball-web for the web front-end
- https://github.com/Tombana/foosball-tracker for the ball tracking system
- https://github.com/Tombana/raspberrypi_balltracker for the ball tracking system (todo: clarify their link, I think that this one is used internally in the second project of this list)

## How to use

### Install nix
First install nix as explained [here](https://nixos.org/download.html#download-nix):
```bash
$ sh <(curl -L https://nixos.org/nix/install) --daemon
```

### Start a virtual machine for the website
To test the raspberry pi system (that basically starts an OS with a navigator that connects to the https://foosball.cwi.nl/ url) you just need to run:

```bash
$ nix build .#foosballrasp-vm
$ rm -f nixos.qcow2 # Remove state from previous runs (sometimes it creates inconsistencies when we build a new derivation)
$ ./result/bin/run-nixos-vm
```

and it will start a qemu with the full OS running! Quite practical to do tests without having any raspberry pi ;-)

Note that a file `.*qcow2` is created when running the VM to keep its state. You can keep it if you want to remove the state of the VW.

Note that for now, `foosballrasp-vm` uses an external server hosted at https://foosball.cwi.nl (so you need a vpn to access it if you are outside of the building). If you want to create an independent instance, you can use `foosballrasp-with-api-vm` instead to build a full website with the database, and `foosballrasp-extern-api-vm` if you want to use a local frontend but use the backend of https://foosball.cwi.nl (useful to share the same database but get a more recent GUI).


### Install on a raspberry pi from a basic NixOs install

To install the OS on a raspberry pi (see also the next section for an alternative method), you need to follow the generic instructions to install NixOs on a raspberry pi [here](https://nixos.wiki/wiki/NixOS_on_ARM#Installation) (see also the page [dedicated to Model 3 B](https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi_3) which is the one used at CWI). Some other ressources include [this tutorial](https://nix.dev/tutorials/installing-nixos-on-a-raspberry-pi).

Here is what I did exactly to install NixOs:
- Download the image from https://hydra.nixos.org/build/195908591
- Uncompress the image (just used the graphical ark extractor from Dolphin but you can also use `unzstd -d`)
- Plug your sd card (at least 16Go, the system + 2G of swap takes 8.5G), use lsblk on linux to find its name and run: `sudo dd if=nixos-sd-image-22.05.3702.c5203abb132-aarch64-linux.img of=/dev/mmcblk0 bs=4M && sync` (make sure to change the names depending on your case)
- Put the card back into the raspberry pi, plug the screen/power and start it. If the card does not boot, you may need to [update manually](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#updating-the-bootloader) the firmware. Also, the version 4 sometimes seem to output the first part of the boot of one hdmi output and the second part the other hdmi output. 

Once you booted into NixOs, it's time to install this project. Unfortunately, NixOs (or actually maybe flake as reported [here](https://github.com/NixOS/nix/issues/3121) and [here](https://github.com/NixOS/nix/pull/6530), I should try without the experimental flake feature) can take quite a lot of RAM to evaluate nixpkgs (some people [reported 1.3G](https://github.com/bennofs/nix-index/issues/64), sometimes more), and the raspberri pi has only 1G of RAM. As a result, the system will randomly hang at some points, without any error. The simplest solution is to add a swapfile (automatically configured after the first install).
```
$ sudo fallocate -l 2G /swapfile
$ sudo chmod 600 /swapfile
$ sudo mkswap /swapfile
$ sudo swapon /swapfile
```
You can verify the amount of free RAM using `sudo free -h` or `sudo swapon`. Other solutions could involve building directly on the laptop, either using the raspberry as a remote builder or using `binfmt` to fake an Aarch64 system or cross-compiling (yeah NixOs makes it a breaze)… but it is not really practical in my opinion.

Usually for a normal install you would just go in `/etc/nixos/configuration.nix` and run `sudo nixos-generate-config` to generate the `hardware-configuration.nix` file, that depends on your hardware (and it's actually what I did the first time to get the content of `hardware-configuration.nix` present in this repo, that I just copied using the SD card on my computer). However since I already included this file in the current project you don't need to run this command (unless you have a different hardware than mine). Instead, clone/copy this repo in `/etc/nixos`. You can either copy this folder from your computer on the SD card directly (to turn off the raspberry pi do `poweroff`), or run directly from the raspberry pi:
```
$ sudo su
# cd /etc/nixos
# nix-shell -p git # if error see below
# git clone https://github.com/cwi-foosball/foosball
```

If you get an error about missing SSL certificates (and/or if it tries to build git from scratch) it is certainly because the system time is wrong (the clock is reset at each reboot on a raspberry pi). You can check the current date with `date` and change it with `date --set="20221231 05:30"` for the December 31 in 2022 at 05:30 (of course adapt the date).

It should create a folder `/etc/nixos/foosball`. To switch your system to this configuration, just do:
```
# nixos-rebuild switch --flake /etc/nixos/foosball#foosballrasp 
```
(This can take a few minutes… the raspberry is not a fast system and NixOs consumes enough RAM during the nixpkgs evaluation that it will surely use the swap file extensively… which is really slow)


Note that for now, `foosballrasp` uses an external server hosted at https://foosball.cwi.nl (so you need a vpn to access it if you are outside of the building). If you want to create an independent instance, you can use `foosballrasp-with-api` instead to build a full website with the database, and `foosballrasp-extern-api` if you want to use a local frontend but use the backend of https://foosball.cwi.nl (useful to share the same database but get a more recent GUI).

### Create directly the SD card from the laptop

To install the system on a raspberry pi, you can also directly build the image of the final SD card (including all the configurations present in the current flake) from your laptop (in my test it is way faster, maybe 5x, and saves band-width as only the final system is downloaded) and burn the final image using `dd` (if you want you can also do upgrades similarly using `nix copy`).

Since the raspberry pi is aarch64 and your laptop is certainly x86_64, you first need to enable `binfmt`to run `aarch64` code on your laptop. In NixOs you just need to add `boot.binfmt.emulatedSystems = [ "aarch64-linux" ];`in your configuration (sorry, I'm not sure how this translate to other systems, maybe see what's in the NixOs module and get inspired by [this tutorial](https://codepyre.com/2019/12/arming-yourself/)). Then, run:
```
$ nix build .#packages.aarch64-linux.foosballrasp-sdcard.config.system.build.sdImage
```
to create the image for the sd card (you can compile similarly images for other configurations in this flake).

Then, you can directly use `dd` as explained above to burn the obtained image on the sd card, boot, and enjoy.
```
$ dd if=./result/sd-image/nixos-sd-image-22.11.20221107.667e558-aarch64-linux.img of=/dev/YOUR_DRIVE bs=4M
```

Then just boot the raspberry pi with this card. It should just work!

To update the system, you can clone the repository in `/etc/nixos`:
```
[pi@nixos]$ cd /etc/nixos/
[pi@nixos]$ sudo git clone https://github.com/cwi-fossball/foosball .
```
