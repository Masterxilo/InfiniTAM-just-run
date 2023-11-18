@echo off

call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64 || call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64

::msbuild InfiniTAM.sln
::msbuild /p:Configuration=Debug InfiniTAM.sln
msbuild /p:Configuration=Release InfiniTAM.sln

