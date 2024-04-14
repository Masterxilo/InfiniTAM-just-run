# InfiniTAM-just-run
Build scripts & binary executable releases for https://github.com/victorprad/InfiniTAM. Read their readme and https://infinitam.org/ to know what this project is all about.

No code was modified, only build infrastructure and dependency management was automated.

## Background
I am absolutely opposed to giving any lengthy instructions to humans.
I found it an apalling waste of our precious time to list dependencies and steps needed to get some code to do what it is supposed to.
One may list dependencies to explain what they are for, but this should never be intended as a way to instruct a human to go and research how to get that dependency installed.
That is a system maintainer's job.

Any worthwhile system can be copied to a vanilla (i.e. empty/freshly set up) instance of it's supported platforms (in this case a blank Ubuntu or Windows machine/vm) and can be compiled and run there with one command: `./run`.

I have created automated scripts that take care of setting up everything required to work with this project.
You can dig into the code to see which dependencies are used and why. Crucially, this is an executable specification of how to get this project up and running. In the future, I hope to add a continuous integration job (GitHub Action) that runs regularly (even if nothing changed) that checks that the instructions still work.

# Requirements
## Minimum
- Platforms: *Ubuntu 22.04* or *Windows 10/11* (**Ubuntu 22.04 in WSL also supported, including GUI output**) on an `x86_64`, aka. `amd64`, processor
  - no additional software needs to be preinstalled, you just need a user with root/sudo/admin privileges on your system (TODO make it work as non-root)

## Additional Hardware
- for WITH_CUDA: CUDA-capable NVIDIA GTX 8800-series or above (tested with NVIDIA GeForce RTX 2080; currently requires some later graphics cards because we depend on a runtime/driver version not available for these old devices... doesn't work on NVIDIA QUADRO K4000 atm for instance); we use CUDA 12.3, which requires at least driver version 525.60.13 ([src](https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html))
- supports original Kinect and XBOX One Kinect (?) for Live Capture of the sparse voxel/volumetric isosurface distance field scene: TODO test these functionalities

# How to Run

## Ubuntu Linux
```bash
./run
```
The user running this must (initially) have sudo privileges so that dependencies can be installed.

Tested on Ubuntu 22.04, amd64.

## Windows
In `cmd` or `powershell`, initially as an admin, do:

```cmd
.\run
```

# TODO
* Make this work in a (Docker) container, maybe also in a devcontainer (expose GUI via X-Server...).
* Set up some kind of CI (gitlabci, circleci, travisci) to continuously test the run script still does what it should on a vanilla system and display the badges in this readme.
* Make the .bat files pause at the end so errors can be inspected, also write a log file.
* Test with Kinect Hardware.
* Try to make it depend on lower minimum CUDA/NVIDIA driver version, i.e. avoid > Runtime API error : CUDA driver version is insufficient for CUDA runtime version. In principle, nothing that happens here requires anything more than the very first version of CUDA probably...
* Give instructions on how to .\run WITH_CUDA (if possible) or automatically run all versions that can run or so initially... make a distinction between build (including fetching dependencies... the complicated part...) and running a build (the easy part).

# Quirks
- this codebase is incompatible with CUDA Toolkit version 11.5, which unfortunately at the moment is the default version installed by `sudo apt-get install -y nvidia-cuda-toolkit` on Ubuntu 22.04
