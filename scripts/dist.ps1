# usage
#  .\scripts\dist.ps1
#
#  $env:WITH_CUDA='true' ; .\scripts\dist.ps1
$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ($env:WITH_CUDA -eq "true") {
    $env:WITH_CUDA=".WITH_CUDA"
} else {
    $env:WITH_CUDA=""
}

mkdir dist -ErrorAction SilentlyContinue


# msvc runtime
cp -Force .\lib\*.dll .\dist

cp .\data\download-teddy.bat .\dist

function f($suffix) {
    # Out-File -Encoding utf8 <- this adds a BOM!
"echo %0 %*
call .\download-teddy.bat
.\InfiniTAM$suffix$env:WITH_CUDA.exe Teddy/calib.txt `"Teddy/Frames/%%04i.ppm`" `"Teddy/Frames/%%04i.pgm`""| Out-File -Encoding ASCII .\dist\InfiniTAM$suffix.with-teddy$env:WITH_CUDA.bat
}

f ''
f '_cli'
