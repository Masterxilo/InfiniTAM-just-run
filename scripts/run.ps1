#
# usage
#  .\scripts\run.ps1
#
#  $env:WITH_CUDA=true ; .\scripts\run.ps1
#

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not ($env:WITH_CUDA -eq "true")) {
    $env:WITH_CUDA="false"
}

echo "Install choco = Chocolatey https://chocolatey.org/install package manager & command if missing..."
try {
    Get-Command choco
} catch {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
Get-Command choco

# run a program, throw on error
function _ {
    $command = $args[0]

    if ($args.Length -gt 1) {
        $cmdArgs = $args[1..($args.Length - 1)]
    } else {
        $cmdArgs = @()
    }

    & $command $cmdArgs
    
    # throw on exit code nonzero
    if ($LASTEXITCODE -ne 0) { throw "Command failed with exit code ${LASTEXITCODE}: $args" }
}

function choco_refreshenv() {
    Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
    refreshenv
}

function choco_install_if_missing {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$package,
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$extra_args
    )
    echo "Ensuring choco package $package is installed..."

    # EITHER: can just install unconditionally
    # it's idempotent 
    # but slower than checking & requires admin privileges
    #_ choco install -y $package @extra_args

    # OR: with check
    try {
        _ choco list -e $package
    } catch {
        _ choco install -y $package @extra_args
    }
    _ choco list -e $package
    choco_refreshenv
}

# Install required tools
choco_install_if_missing visualstudio2022buildtools
choco_install_if_missing make
# this is required for nmake, cl, msbuild, link:
choco_install_if_missing visualstudio2022-workload-vctools
choco_install_if_missing cmake --installargs 'ADD_CMAKE_TO_PATH=System'

if ($env:WITH_CUDA -eq "true") {
    # if CUDA is required, ensure it is installed
    choco_install_if_missing cuda

    # check required tools are (now) installed and in PATH
    Get-Command nvcc
    &(gi "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v*\bin\nvcc.exe") --version
}

# check required tools are (now) installed and in PATH
Get-Command make
_ make --version

Get-Command cmake
_ cmake --version

# InfiniTAM specific dependencies (C/C++ libraries)

# OpenNI2
# TODO not really required ? skip entirely?
if ($False) {
    if (-not (Test-Path "C:\Program Files\OpenNI2")) {
        #wget.exe --no-clobber https://s3.amazonaws.com/com.occipital.openni/OpenNI-Windows-x64-2.2.0.33.zip
        #curl.exe https://s3.amazonaws.com/com.occipital.openni/OpenNI-Windows-x64-2.2.0.33.zip -o OpenNI-Windows-x64-2.2.0.33.zip
        cp ./lib/OpenNI-Windows-x64-2.2.0.33.zip .
        Expand-Archive -Force OpenNI-Windows-x64-2.2.0.33.zip

        # note: contains an .msi installer... install to
        # and also install the PrimeSense driver = XBOX Kinect sensor Windows driver... (PrimeSense made that tech, which is now in Apple's iPhone X face ID...)
        # .\OpenNI2\

        # TODO this does not wait for the installation to finish, need to busy-wait! runs async...
        #&.\OpenNI-Windows-x64-2.2.0.33\OpenNI-Windows-x64-2.2.msi /quiet

        # syncrhonous install
        echo "Installing OpenNI2..."
        #msiexec.exe /I 
        .\OpenNI-Windows-x64-2.2.0.33\OpenNI-Windows-x64-2.2.msi #/quiet # only works if admin...
        while (-not (Test-Path "C:\Program Files\OpenNI2")) {
            Start-Sleep -Seconds 1
            
            echo "still Installing OpenNI2..."
        }


        (gi "C:\Program Files\OpenNI2").FullName
    }
}

# FreeGLUT, a new GLUT, OpenGL Utility Toolkit, for GUI & real-time graphics
# https://github.com/FreeGLUTProject/freeglut
# https://freeglut.sourceforge.net/index.php#download
# https://www.transmissionzero.co.uk/software/freeglut-devel/
if (-not (Test-Path .\freeglut)) {
    #curl.exe -L https://www.transmissionzero.co.uk/files/software/development/GLUT/freeglut-MSVC.zip -o freeglut-MSVC.zip

    cp ./lib/freeglut-MSVC.zip .
    Expand-Archive -Force freeglut-MSVC.zip -DestinationPath .
}

# locate scripts and folders
$build_bat=(gi ./scripts/build.bat).FullName
$env:GLUT_ROOT=(gi ./freeglut).FullName
$env:GLUT_INCLUDE_DIR=(gi ./freeglut/include).FullName
$env:GLUT_LIBRARY=(gi ./freeglut/lib/x64/freeglut.lib).FullName
$env:OPEN_NI_ROOT=(gi "C:\Program Files\OpenNI2").FullName

# Change directory to where we will build
# TODO use try/catch/trap popd to return to invoking directory on failure - changed current directory is inherited/persistent from scripts to parent shell in powershell, unlike bash!
cd .\InfiniTAM

# Cleanup, optional, for full rebuild; full rebuild is required if parameters like WITH_CUDA are changed and in general is more reproducible, but slower...
git clean -fX
rm -re -fo .\build -ErrorAction SilentlyContinue

# Ensure build folder exists
mkdir -Force .\build >$null

echo "Building..."
# TODO try to use InfiniTAM\build-win.sh in WSL?... or cygwin?
cd .\build

if ($env:WITH_CUDA -eq "true") {
    _ cmake .. `
    "-DOPEN_NI_ROOT=$env:OPEN_NI_ROOT" "-DGLUT_ROOT=$env:GLUT_ROOT" "-DGLUT_INCLUDE_DIR=$env:GLUT_INCLUDE_DIR" "-DGLUT_LIBRARY=$env:GLUT_LIBRARY" `
    -DWITH_CUDA=true

} else {
    _ cmake .. `
    "-DOPEN_NI_ROOT=$env:OPEN_NI_ROOT" "-DGLUT_ROOT=$env:GLUT_ROOT" "-DGLUT_INCLUDE_DIR=$env:GLUT_INCLUDE_DIR" "-DGLUT_LIBRARY=$env:GLUT_LIBRARY" `
    -DWITH_CUDA=false -DCUDA_FOUND=false -DCUDA_TOOLKIT_INCLUDE=NOTFOUND
}

_ $build_bat

# after the build completes, collect & create executables (binary distribution):
cd ..\..
./scripts/dist.ps1
echo "Build Succeeded."

# run it

# must have driver to run (not required for compilation)
$x=""
if ($env:WITH_CUDA -eq "true") {
    $x=".WITH_CUDA"
    if (-not (Test-Path "C:\Program Files\NVIDIA Corporation")) {
        _ choco install -y nvidia-display-driver # TODO it seems that when installed like this, the nvidia driver doesn't work in WSL? the WITH_CUDA version immediately crashes then... (segfault)
    }
}

echo "Running..."
pushd .\dist
try {
    echo "Running the interactive InfiniTAM gui. Use b or n key to start integrating images from the Teddy example dataset into the 3D scene!"
    &".\InfiniTAM.with-teddy$x.bat"

    # run the batch mode cli, no graphical output
    echo "Running the batch mode InfiniTAM cli. Integrating images from the Teddy example dataset into the 3D scene..."
    &".\InfiniTAM_cli.with-teddy$x.bat"
} finally {
    popd
}
