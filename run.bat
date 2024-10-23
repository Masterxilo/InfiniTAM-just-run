@echo off

:: usage:
::
::  .\run.bat
::
::  set WITH_CUDA=true
::  .\run.bat
::
::  $env:WITH_CUDA='true' ; .\run
::

echo "Allowing execution of powershell scripts..."
powershell.exe -Command "Set-ExecutionPolicy -Force Unrestricted"
echo "Executing .\scripts\run.ps1 ..."
powershell.exe -File .\scripts\run.ps1
