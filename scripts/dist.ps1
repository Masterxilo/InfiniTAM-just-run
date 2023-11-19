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


cp .\InfiniTAM\build\Apps\InfiniTAM_cli\Release\InfiniTAM_cli.exe ".\dist\InfiniTAM_cli$env:WITH_CUDA.exe"
cp -Force .\InfiniTAM\build\Apps\InfiniTAM_cli\Release\*.dll .\dist

cp .\InfiniTAM\build\Apps\InfiniTAM\Release\InfiniTAM.exe ".\dist\InfiniTAM$env:WITH_CUDA.exe"
cp -Force .\InfiniTAM\build\Apps\InfiniTAM\Release\*.dll .\dist

cp .\data\download-teddy.ps1 .\dist

function f($suffix) {
"echo %0 %*
powershell.exe .\download-teddy.ps1
.\InfiniTAM$suffix.exe Teddy/calib.txt `"Teddy/Frames/%%04i.ppm`" `"Teddy/Frames/%%04i.pgm`""| Out-File -Encoding utf8 .\dist\InfiniTAM$suffix.with-teddy$env:WITH_CUDA.bat
}

f ''
f '_cli'
