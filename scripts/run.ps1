# usage
#  .\scripts\run.ps1
#
#  $env:WITH_CUDA=true ; .\scripts\run.ps1
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not ($env:WITH_CUDA -eq "true")) {
    $env:WITH_CUDA="false"
}

# Install Chocolatey https://chocolatey.org/install
try {
    Get-Command choco
} catch {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

try {
    Get-Command cmake
} catch {
    choco install -y visualstudio2022buildtools make
    #choco uninstall -y cmake cmake.install
    choco install -y cmake --installargs 'ADD_CMAKE_TO_PATH=System'

    Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
    refreshenv
}

make --version
cmake --version

# this is required for nmake, cl, msbuild, link:
if (-not (Test-Path "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat")) {
    choco install -y visualstudio2022-workload-vctools
}

if ($env:WITH_CUDA -eq "true") {
    try {
        &(gi "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v*\bin\nvcc.exe") --version
    } catch {
        choco install -y cuda

        Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
        refreshenv
    }

    &(gi "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v*\bin\nvcc.exe") --version
}

if ($False) {} # TODO OpenNI2 not really required ? skip entirely?
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


# https://github.com/FreeGLUTProject/freeglut
# https://freeglut.sourceforge.net/index.php#download
# https://www.transmissionzero.co.uk/software/freeglut-devel/
if (-not (Test-Path .\freeglut)) {
    #curl.exe -L https://www.transmissionzero.co.uk/files/software/development/GLUT/freeglut-MSVC.zip -o freeglut-MSVC.zip

    cp ./lib/freeglut-MSVC.zip .
    Expand-Archive -Force freeglut-MSVC.zip -DestinationPath .
}

$build_bat=(gi ./scripts/build.bat).FullName

$env:GLUT_ROOT=(gi ./freeglut).FullName
$env:GLUT_INCLUDE_DIR=(gi ./freeglut/include).FullName
$env:GLUT_LIBRARY=(gi ./freeglut/lib/x64/freeglut.lib).FullName
$env:OPEN_NI_ROOT=(gi "C:\Program Files\OpenNI2").FullName

cd .\InfiniTAM

# Cleanup, optional, for full rebuild; full rebuild is required if parameters like WITH_CUDA are changed and in general is more reproducible, but slower...
git clean -fX
rm -re -fo .\build -ErrorAction SilentlyContinue

# Ensure build folder exists
mkdir -Force .\build >$null

# TODO try to use InfiniTAM\build-win.sh in WSL?... or cygwin?

# Manual build
cd .\build

if ($env:WITH_CUDA -eq "true") {
    cmake .. `
    "-DOPEN_NI_ROOT=$env:OPEN_NI_ROOT" "-DGLUT_ROOT=$env:GLUT_ROOT" "-DGLUT_INCLUDE_DIR=$env:GLUT_INCLUDE_DIR" "-DGLUT_LIBRARY=$env:GLUT_LIBRARY" `
    -DWITH_CUDA=true

} else {
    cmake .. `
    "-DOPEN_NI_ROOT=$env:OPEN_NI_ROOT" "-DGLUT_ROOT=$env:GLUT_ROOT" "-DGLUT_INCLUDE_DIR=$env:GLUT_INCLUDE_DIR" "-DGLUT_LIBRARY=$env:GLUT_LIBRARY" `
    -DWITH_CUDA=false -DCUDA_FOUND=false -DCUDA_TOOLKIT_INCLUDE=NOTFOUND

}

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

&$build_bat

# after the build completes:
cd ..\..

./scripts/dist.ps1

# run it once

# must have driver to run (not required for compilation)
$x=""
if ($env:WITH_CUDA -eq "true") {
    $x=".WITH_CUDA"
    if (-not (Test-Path "C:\Program Files\NVIDIA Corporation")) {
        choco install -y nvidia-display-driver # TODO it seems that when installed like this, the nvidia driver doesn't work in WSL? the WITH_CUDA version immediately crashes then... (segfault)
    }
}

pushd .\dist
try {
&".\InfiniTAM_cli.with-teddy$x.bat"
&".\InfiniTAM.with-teddy$x.bat"
} finally {
    popd
}
