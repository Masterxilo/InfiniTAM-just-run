@echo off

call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64

::msbuild InfiniTAM.sln
msbuild /p:Configuration=Release InfiniTAM.sln
