# usage
#  .\dist.ps1
#
#  $env:WITH_CUDA=true ; .\dist.ps1
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
cp .\scripts\InfiniTAM*.bat .\dist
