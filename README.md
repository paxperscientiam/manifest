# manifest
manifest -- execute, in case of Doomsday.

This is a `bash` program that generates manifests of packages from various package managers. Designed with love for the paranoid.



# installation
```bash
make
make install
```
By default, `manifest` is installed into `${HOME}/bin/paxperscientiam/`.


# uninstall
```bash
make uninstall
```
This will move `${HOME}/bin/paxperscientiam/manifest` to a temporary folder.



# Examples
Execute `manifest cron emacs` to backup user crontab and create a cask file for emacs.
Execute `manifest -h` to see help menu.


# Supported
* composer
* emacs
* lunchy
* gem
* npm
* pip
* ... more coming


> Disclaimer: EXECUTE AT YOUR OWN PERIL.

*Requirements.*
* Bash ≥ 4.2
