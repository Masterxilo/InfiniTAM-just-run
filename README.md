# InfiniTAM-just-run
Build scripts & releases for https://github.com/victorprad/InfiniTAM. Read their readme and https://infinitam.org/ to know what this project is all about.


## Background
I am absolutely opposed to giving any lengthy instructions to humans.
I found it an apalling waste of our precious time to list dependencies and steps needed get this code to do what it is supposed to.
One may list dependencies to explain what they are for, but never for a human to research how to get that dependency installed.
That is a system maintainer's job.

I have created automated scripts that take care of setting up everything required to work with this project.
You can dig into the code to see which dependencies are used and why.

# Requirements
## Minimum
- *Ubuntu 22.04* or *Windows 10/11* (Ubuntu 22.04 in WSL also supported) on an `x86_64`, aka. `amd64`, processor
  - no additional software needs to be preinstalled, you just need a user with root/sudo/admin privileges on your system

## Additional Hardware
- for WITH_CUDA: CUDA-capable NVIDIA GTX 8800-series or above (tested with NVIDIA GeForce RTX 2080); we use CUDA 12.3, which requires at least driver version 525.60.13 ([src](https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/index.html))
- supports original Kinect and XBOX One Kinect (?) for Live Capture: TODO test

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
Make this work in a (Docker) container, maybe in a devcontainer. Set up some kind of CI (gitlabci, circleci, travisci) to continuously test the run script still does what it should on a vanilla system.

It seems the WSL built executables run on Ubuntu afterall, so remove the .WSL concept/distinction again.

# Quirks
- this codebase is incompatible with CUDA Toolkit version 11.5, which unfortunately at the moment is the default version installed by `sudo apt-get install -y nvidia-cuda-toolkit` on Ubuntu 22.04
