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

make --version
cmake --version

try {
    Get-Command nvcc
} catch {
    choco install -y cuda

    Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
    refreshenv
}
nvcc --version


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

$build_bat=(gi ./scripts/build.bat).FullName

$env:GLUT_ROOT=(gi ./freeglut).FullName
$env:GLUT_INCLUDE_DIR=(gi ./freeglut/include).FullName
$env:GLUT_LIBRARY=(gi ./freeglut/lib/x64/freeglut.lib).FullName
$env:OPEN_NI_ROOT=(gi ./OpenNI2).FullName

cd .\InfiniTAM
git clean -fX
rm -re -fo .\build
mkdir -Force .\build >$null

cd .\build
cmake .. `
    "-DOPEN_NI_ROOT=$env:OPEN_NI_ROOT" "-DGLUT_ROOT=$env:GLUT_ROOT" "-DGLUT_INCLUDE_DIR=$env:GLUT_INCLUDE_DIR" "-DGLUT_LIBRARY=$env:GLUT_LIBRARY" `
    -DWITH_CUDA=TRUE
 #   -DWITH_OPENNI=TRUE # todo doesnt work yet... i don't see x64-Release\OpenNI2.dll ?...

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

&$build_bat

# after the build completes:
cd ..\..
#&.\InfiniTAM\build\Apps\InfiniTAM\Debug\InfiniTAM.exe Teddy/calib.txt Teddy/Frames/%04i.ppm Teddy/Frames/%04i.pgm
&.\InfiniTAM\build\Apps\InfiniTAM\Release\InfiniTAM.exe Teddy/calib.txt Teddy/Frames/%04i.ppm Teddy/Frames/%04i.pgm
