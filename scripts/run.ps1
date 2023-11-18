$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

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

if (-not (Test-Path .\OpenNI2)) {
    #wget.exe --no-clobber https://s3.amazonaws.com/com.occipital.openni/OpenNI-Windows-x64-2.2.0.33.zip
    #curl.exe https://s3.amazonaws.com/com.occipital.openni/OpenNI-Windows-x64-2.2.0.33.zip -o OpenNI-Windows-x64-2.2.0.33.zip
    cp ./lib/OpenNI-Windows-x64-2.2.0.33.zip .
    Expand-Archive OpenNI-Windows-x64-2.2.0.33.zip

    # note: contains an .msi installer... install to
    # and also install the PrimeSense driver = XBOX Kinect sensor Windows driver... (PrimeSense made that tech, which is now in Apple's iPhone X face ID...)
    # .\OpenNI2\
}

# https://github.com/FreeGLUTProject/freeglut
# https://freeglut.sourceforge.net/index.php#download
# https://www.transmissionzero.co.uk/software/freeglut-devel/
if (-not (Test-Path .\freeglut)) {
    #curl.exe -L https://www.transmissionzero.co.uk/files/software/development/GLUT/freeglut-MSVC.zip -o freeglut-MSVC.zip

    cp ./lib/freeglut-MSVC.zip .
    Expand-Archive freeglut-MSVC.zip -DestinationPath .
}

$env:GLUT_ROOT=(ls ./freeglut).FullName
$env:GLUT_INCLUDE_DIR=(ls ./freeglut/include).FullName
$env:GLUT_LIBRARY=(ls ./freeglut/lib/x64/freeglut.lib).FullName
$env:OPEN_NI_ROOT=(ls ./OpenNI2).FullName

mkdir -Force .\InfiniTAM\build >$null
cd .\InfiniTAM
git clean -fX

cd .\build
cmake .. "-DOPEN_NI_ROOT=$env:OPEN_NI_ROOT" "-DGLUT_ROOT=$env:GLUT_ROOT" "-DGLUT_INCLUDE_DIR=$env:GLUT_INCLUDE_DIR" "-DGLUT_LIBRARY=$env:GLUT_LIBRARY"
