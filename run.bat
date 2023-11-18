@echo off

:: usage
::  .\run.bat
::
::  set WITH_CUDA=true
::  .\run.bat

powershell.exe -Command "Set-ExecutionPolicy -Force Unrestricted"
powershell.exe -File .\scripts\run.ps1
