# szcdf-core

The core component of the SZCDF (Stephen Zhao Configuration Dot Files) system.

## How to Use

Run the following command:
```sh
git clone git@github.com:szcdf/szcdf-core.git && cd szcdf-core && make install
```
Then follow the instructions in the installer.

## How to Develop

### How to Test

Prerequisite: docker.

1. Run `make` to build a docker image and start a container from it.
2. Run `./install.sh` to test the installer.
  - Run `./reset.sh` to undo the installation when you need to retest the installer.
  - Optionally install any packages you may need to aid in testing (e.g. `sudo apt install vim` to test the vimconfig module).
3. Run `bash` to start a new bash shell and see the dotfiles come into effect.
4. Test the final environment.